;;; config.el -*- lexical-binding: t; -*-


(setq doom-theme 'doom-one)
;; Override background to Tokyo Night color
(after! doom-themes
  (custom-set-faces!
    '(default :background "#1a1b26")
    '(fringe :background "#1a1b26")
    '(solaire-default-face :background "#1a1b26")
    '(solaire-fringe-face :background "#1a1b26")))

;; Disable all syntax highlighting except comments
(setq doom-themes-enable-bold nil
      doom-themes-enable-italic nil)
;; Disable line numbers
(setq display-line-numbers-type nil)

;; Auto-save files on idle
(auto-save-visited-mode +1)

;; Hide modeline by default
(global-hide-mode-line-mode +1)

;; Disable syntax highlighting globally, except org-mode
(global-font-lock-mode -1)
(add-hook 'org-mode-hook #'font-lock-mode)

;; Font configuration
(setq doom-font (font-spec :family "CommitMono Nerd Font" :size 32)
      doom-big-font (font-spec :family "CommitMono Nerd Font" :size 40)
      doom-variable-pitch-font (font-spec :family "DejaVu Sans" :size 32))

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

;; Rename org-roam node: update title and rename file to match
(defun +org/rename-node (new-title)
  "Rename the current org-roam node: update #+title and rename the file."
  (interactive "sNew title: ")
  (unless (org-roam-file-p)
    (user-error "Not an org-roam file"))
  (let* ((old-file (buffer-file-name))
         (dir (file-name-directory old-file))
         (slug (org-roam--title-to-slug new-title))
         (new-file (expand-file-name (concat slug ".org") dir)))
    (save-excursion
      (goto-char (point-min))
      (if (re-search-forward "^#\\+title:.*$" nil t)
          (replace-match (concat "#+title: " new-title))
        (user-error "No #+title found")))
    (save-buffer)
    (unless (string= old-file new-file)
      (rename-file old-file new-file)
      (set-visited-file-name new-file t t)
      (org-roam-db-sync))))
(map! :leader
      :desc "Rename org-roam node"
      "n R" #'+org/rename-node)

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

;; Capture templates for org-roam
(after! org-roam
  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "${slug}.org"
                              "#+title: ${title}\n#+date: %U\n")
           :unnarrowed t)
          ("p" "public" plain "%?"
           :target (file+head "${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: :public:\n")
           :unnarrowed t))))

;; ox-hugo configuration
(after! ox-hugo
  (setq org-hugo-base-dir "~/org-roam-site"
        org-hugo-default-section-directory "posts"))

;; Export all public org-roam files to Hugo
(defun +org/hugo-publish-all ()
  "Export all org-roam files tagged :public: to Hugo via ox-hugo."
  (interactive)
  (dolist (f (org-roam-list-files))
    (with-current-buffer (find-file-noselect f)
      (when (member "public" (org-get-tags))
        (org-hugo-export-wim-to-md)))))

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
