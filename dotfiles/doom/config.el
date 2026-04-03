;;; config.el -*- lexical-binding: t; -*-

;; Use bash internally to avoid issues with non-POSIX shells
(setq shell-file-name (executable-find "bash"))
;; But keep fish for terminal emulators
(setq-default vterm-shell "/run/current-system/sw/bin/fish")
(setq-default explicit-shell-file-name "/run/current-system/sw/bin/fish")

;; Load stylix-generated base16 theme (colors from NixOS stylix module)
(add-to-list 'custom-theme-load-path "~/.config/doom-stylix")
(setq doom-theme 'stylix-theme)
;; Match mini.base16 (neovim): cursor uses foreground (base05), not red (base08)
(add-hook! 'doom-load-theme-hook
  (set-face-attribute 'cursor nil :background (face-foreground 'default)))
;; Disable line numbers
(setq display-line-numbers-type nil)

;; Auto-save files on idle
(auto-save-visited-mode +1)

;; Hide modeline by default
(global-hide-mode-line-mode +1)

;; Uncomment to disable syntax highlighting globally (re-enable per mode as needed):
;; (global-font-lock-mode -1)
;; (add-hook 'org-mode-hook #'font-lock-mode)

;; Font configuration
(let ((mono (or (getenv "NIXOS_MONO_FONT") "CommitMono"))
      (serif (or (getenv "NIXOS_SERIF_FONT") "iA Writer Quattro S")))
  (setq doom-font (font-spec :family mono :size 16)
        doom-big-font (font-spec :family mono :size 20)
        doom-variable-pitch-font (font-spec :family serif :size 16)))

;; Disable automatic eldoc popups
(setq eldoc-idle-delay most-positive-fixnum)

;; Kill the other window without switching to it
(defun kill-other-window ()
  (interactive)
  (if (one-window-p)
      (message "No other window to kill")
    (save-selected-window
      (other-window 1)
      (delete-window))))
(map! :leader
      :desc "Kill other window"
      "w o" #'kill-other-window)

;; Swap SPC ; and SPC :
(map! :leader
      ";" #'execute-extended-command
      ":" #'pp-eval-expression)

;; Org mode configuration
(setq org-directory "~/org")

;; Elfeed: point elfeed-org at our dotfiles-managed elfeed.org
(setq rmh-elfeed-org-files (list (expand-file-name "elfeed.org" doom-user-dir)))
(after! org
  (setq org-hide-emphasis-markers t)
  (setq org-log-done 'time)
  (setq org-agenda-hide-tags-regexp "agenda"))

;; Log time to the task at point with a start time, duration, and optional date
(defun +org/log-time (start-time minutes &optional date)
  "Add MINUTES of clocked time starting at START-TIME to the org heading at point.
START-TIME is a string like \"9:30\" or \"0900\".
DATE is optional: \"02-25\" (mm-dd, current year) or \"2026-02-25\" (yyyy-mm-dd).
If empty or omitted, today is used."
  (interactive
   (list (read-string "Start time (e.g. 0900 or 9:00): ")
         (read-number "Minutes: ")
         (org-read-date nil nil nil "Date: ")))
  (require 'org-clock)
  (org-back-to-heading t)
  (let* ((time-norm (if (string-match ":" start-time)
                        start-time
                      (replace-regexp-in-string
                       "\\`\\([0-9]\\{1,2\\}\\)\\([0-9]\\{2\\}\\)\\'"
                       "\\1:\\2" start-time)))
         (hm (split-string time-norm ":"))
         (parsed-date (parse-time-string date))
         (start (encode-time 0 (string-to-number (cadr hm)) (string-to-number (car hm))
                             (nth 3 parsed-date) (nth 4 parsed-date) (nth 5 parsed-date)))
         (end (time-add start (seconds-to-time (* minutes 60)))))
    (org-clock-find-position nil)
    (insert-before-markers
     "CLOCK: "
     (org-timestamp-translate (org-timestamp-from-time start t t) 'end)
     "--"
     (org-timestamp-translate (org-timestamp-from-time end t t) 'end)
     " => " (format "%5s" (org-duration-from-minutes minutes)) "\n"))
  (message "Logged %d minutes from %s" minutes start-time))
(map! :leader
      :desc "Log time to task"
      "n t" #'+org/log-time)

;; UUIDv7 generator
(defun +org/uuidv7 ()
  "Generate a UUIDv7 string (48-bit ms timestamp + random, per RFC 9562)."
  (let* ((ms (truncate (* 1000 (float-time))))
         (rand-a (random 4096))
         (rand-b-hi (logior #x8000 (random #x4000)))
         (rand-b-lo (logior (ash (random #x1000000) 24)
                            (random #x1000000))))
    (format "%08x-%04x-7%03x-%04x-%012x"
            (ash ms -16)
            (logand ms #xffff)
            rand-a
            rand-b-hi
            rand-b-lo)))

;; Rename org-roam node: update title and EXPORT_FILE_NAME (file stays as UUIDv7)
(defun +org/rename-node (new-title)
  "Rename the current org-roam node: update #+title and #+EXPORT_FILE_NAME."
  (interactive "sNew title: ")
  (unless (org-roam-file-p)
    (user-error "Not an org-roam file"))
  (let ((slug (org-roam--title-to-slug new-title)))
    (save-excursion
      (goto-char (point-min))
      (if (re-search-forward "^#\\+title:.*$" nil t)
          (replace-match (concat "#+title: " new-title))
        (user-error "No #+title found"))
      (goto-char (point-min))
      (if (re-search-forward "^#\\+EXPORT_FILE_NAME:.*$" nil t)
          (replace-match (concat "#+EXPORT_FILE_NAME: " slug))
        (when (re-search-forward "^:END:" nil t)
          (end-of-line)
          (insert (format "\n#+EXPORT_FILE_NAME: %s" slug)))))
    (save-buffer)
    (org-roam-db-sync)))
(map! :leader
      :desc "Rename org-roam node"
      "n R" #'+org/rename-node)

;; Migrate existing org-roam files to UUIDv7 filenames
(defun +org/migrate-to-uuidv7 ()
  "Rename all org-roam files to UUIDv7 filenames, adding EXPORT_FILE_NAME."
  (interactive)
  (require 'org-roam)
  (let ((files (org-roam-list-files))
        (count 0))
    (dolist (f files)
      (let* ((old-name (file-name-nondirectory f))
             (slug (file-name-sans-extension old-name))
             (export-name (if (string= slug "start_here") "readme" slug))
             (new-name (concat (+org/uuidv7) ".org"))
             (new-path (expand-file-name new-name (file-name-directory f))))
        ;; Skip files already using UUIDv7 names
        (unless (string-match-p "^[0-9a-f]\\{8\\}-[0-9a-f]\\{4\\}-7" old-name)
          (with-current-buffer (find-file-noselect f)
            (save-excursion
              (goto-char (point-min))
              (unless (re-search-forward "^#\\+EXPORT_FILE_NAME:" nil t)
                (goto-char (point-min))
                (when (re-search-forward "^:END:" nil t)
                  (end-of-line)
                  (insert (format "\n#+EXPORT_FILE_NAME: %s" export-name)))))
            (save-buffer)
            (rename-file f new-path)
            (set-visited-file-name new-path t t)
            (save-buffer))
          (cl-incf count)
          (sleep-for 0.002))))
    (org-roam-db-sync)
    (message "Migrated %d files to UUIDv7. Database synced." count)))

;; Markdown mode configuration
(after! markdown-mode
  (setq-default markdown-hide-markup t)
  (setq markdown-list-item-bullets '("-")))

;; Org-roam configuration
(setq org-roam-directory "~/org-roam")
(setq org-roam-db-location "~/org-roam/org-roam.db")

;; Auto-tag roam files with :agenda: when they gain agenda-relevant content
(defun +org/ensure-agenda-tag ()
  "Add :agenda: filetag to current org-roam file if not already present.
Also refreshes the agenda file cache."
  (interactive)
  (when (and (buffer-file-name) (org-roam-file-p))
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (unless (re-search-forward "^#\\+filetags:.*:agenda:" nil t)
          (goto-char (point-min))
          (if (re-search-forward "^#\\+filetags:\\(.*\\)" nil t)
              (replace-match (concat (match-string 0) " :agenda:"))
            (while (re-search-forward "^#\\+.*:.*$" nil t))
            (end-of-line)
            (insert "\n#+filetags: :agenda:"))
          (save-buffer)
          (let ((f (buffer-file-name)))
            (unless (member f org-agenda-files)
              (push f org-agenda-files))))))))

(add-hook 'org-after-todo-state-change-hook #'+org/ensure-agenda-tag)
(add-hook 'org-schedule-hook #'+org/ensure-agenda-tag)
(add-hook 'org-deadline-hook #'+org/ensure-agenda-tag)

;; Build agenda file list from roam files tagged :agenda:
(defun +org/agenda-files ()
  "Return org-roam files that have the :agenda: filetag."
  (seq-filter
   (lambda (f)
     (with-temp-buffer
       (insert-file-contents f nil 0 512)
       (re-search-forward "^#\\+filetags:.*:agenda:" nil t)))
   (org-roam-list-files)))

(defvar +org/agenda-files-cache nil)

(defun +org/refresh-agenda-files ()
  "Rebuild the agenda file cache."
  (setq +org/agenda-files-cache (+org/agenda-files))
  (setq org-agenda-files +org/agenda-files-cache))

(after! org-roam
  (+org/refresh-agenda-files))

;; Capture templates for org-roam (UUIDv7 filenames)
(after! org-roam
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "%(+org/uuidv7).org"
                              "#+title: ${title}\n#+date: %U\n#+EXPORT_FILE_NAME: ${slug}\n")
           :unnarrowed t)
          ("p" "public" plain "%?"
           :target (file+head "%(+org/uuidv7).org"
                              "#+title: ${title}\n#+date: %U\n#+EXPORT_FILE_NAME: ${slug}\n#+filetags: :public:\n")
           :unnarrowed t))))

;; ox-hugo configuration
(after! ox-hugo
  (setq org-hugo-base-dir "~/code/blog"
        org-hugo-default-section-directory "")

  ;; Only export #+hugo_tags: to Hugo front matter, never filetags
  (defadvice! +org/hugo-no-filetags-as-tags (orig-fn &rest args)
    :around #'org-hugo--get-tags
    (let ((org-use-tag-inheritance nil))
      (apply orig-fn args))))

;; Export all public org-roam files to Hugo
(defun +org/hugo-publish-all ()
  "Export all org-roam files tagged :public: to Hugo via ox-hugo."
  (interactive)
  (require 'ox-hugo)
  (let ((exported 0)
        (skipped 0)
        (failed nil))
    (dolist (f (org-roam-list-files))
      (with-current-buffer (find-file-noselect f)
        (if (not (member "public" (+org/file-tags)))
            (cl-incf skipped)
          (condition-case err
              (progn
                (org-hugo-export-wim-to-md)
                (cl-incf exported))
            (error
             (push (cons f (error-message-string err)) failed)
             (message "ox-hugo: FAILED %s: %s"
                      (file-name-nondirectory f)
                      (error-message-string err)))))))
    (+org/hugo-ensure-section-indexes)
    (message "ox-hugo: %d exported, %d skipped, %d failed"
             exported skipped (length failed))
    (when failed
      (message "Failed:\n%s"
               (mapconcat (lambda (p) (format "  %s: %s" (car p) (cdr p)))
                          failed "\n")))))

(defun +org/file-tags ()
  "Return file-level tags from #+filetags as a list of strings."
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (when (re-search-forward "^#\\+filetags:\\s-*\\(.*\\)" nil t)
        (split-string (match-string-no-properties 1) ":" t)))))

(defun +org/hugo-ensure-section-indexes ()
  "Create _index.md for any content subdirectory missing one."
  (let ((content-dir (expand-file-name "content" org-hugo-base-dir)))
    (dolist (dir (directory-files content-dir t "\\`[^.]"))
      (when (file-directory-p dir)
        (let ((index (expand-file-name "_index.md" dir)))
          (unless (file-exists-p index)
            (write-region
             (format "---\ntitle: \"%s\"\n---\n"
                     (capitalize (file-name-nondirectory dir)))
             nil index)))))))

;; ============ Clockify API ============

(defvar +clockify/api-base "https://api.clockify.me/api/v1")
(defvar +clockify/workspace-id "699de28e73587cb175abd341")
(defvar +clockify/project-msa "699de2e373587cb175abdedb")
(defvar +clockify/default-project +clockify/project-msa)

(defun +clockify/api-key ()
  "Read Clockify API key from sops secret."
  (string-trim (with-temp-buffer
                 (insert-file-contents "/run/secrets/msa-clockify-api-key")
                 (buffer-string))))

(defun +clockify/request (method endpoint &optional body)
  "Make a Clockify API request. Returns parsed JSON."
  (let* ((url-request-method method)
         (url-request-extra-headers
          `(("X-Api-Key" . ,(+clockify/api-key))
            ("Content-Type" . "application/json")))
         (url-request-data (when body (encode-coding-string (json-encode body) 'utf-8)))
         (buf (url-retrieve-synchronously
               (concat +clockify/api-base endpoint) t)))
    (unwind-protect
        (with-current-buffer buf
          (goto-char (point-min))
          (re-search-forward "\n\n")
          (json-read))
      (kill-buffer buf))))

(defun +clockify/create-time-entry (description start-iso end-iso &optional project-id)
  "Create a Clockify time entry.
START-ISO and END-ISO are ISO 8601 strings like 2026-03-12T09:00:00.000Z.
PROJECT-ID defaults to MSA."
  (+clockify/request "POST"
                     (format "/workspaces/%s/time-entries" +clockify/workspace-id)
                     `((start . ,start-iso)
                       (end . ,end-iso)
                       (description . ,description)
                       (projectId . ,(or project-id +clockify/default-project)))))

(defun +clockify/test ()
  "Create a dummy 1-hour time entry on Clockify to verify API works."
  (interactive)
  (let ((result (+clockify/create-time-entry
                 "Test entry from Emacs"
                 "2026-03-12T09:00:00.000Z"
                 "2026-03-12T10:00:00.000Z")))
    (message "Created entry: %s" (alist-get 'id result))))

(defun +clockify/delete-time-entry (entry-id)
  "Delete a Clockify time entry by ID."
  (let* ((url-request-method "DELETE")
         (url-request-extra-headers
          `(("X-Api-Key" . ,(+clockify/api-key))
            ("Content-Type" . "application/json")))
         (buf (url-retrieve-synchronously
               (concat +clockify/api-base
                       (format "/workspaces/%s/time-entries/%s"
                               +clockify/workspace-id entry-id))
               t)))
    (unwind-protect
        (with-current-buffer buf
          (goto-char (point-min))
          (when (re-search-forward "^HTTP/[0-9.]+ \\([0-9]+\\)" nil t)
            (< (string-to-number (match-string 1)) 300)))
      (kill-buffer buf))))

(defun +clockify/clock-hash (clock-line)
  "Return an 8-char MD5 hash of CLOCK-LINE text."
  (substring (md5 (string-trim clock-line)) 0 8))

(defun +clockify/parse-sync-property (prop)
  "Parse CLOCKIFY_SYNC property string into alist of (hash . id).
PROP is like \"a1b2c3=69b1d32f,d4e5f6=69b1d44a\"."
  (when (and prop (not (string-empty-p prop)))
    (mapcar (lambda (pair)
              (let ((parts (split-string pair "=")))
                (cons (car parts) (cadr parts))))
            (split-string prop ","))))

(defun +clockify/write-sync-property (alist)
  "Write alist of (hash . id) pairs as CLOCKIFY_SYNC property at point."
  (if alist
      (org-entry-put nil "CLOCKIFY_SYNC"
                     (mapconcat (lambda (pair)
                                  (format "%s=%s" (car pair) (cdr pair)))
                                alist ","))
    (org-entry-delete nil "CLOCKIFY_SYNC")))
