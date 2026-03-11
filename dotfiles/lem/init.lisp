;;; init.lisp — Doom Emacs-style SPC-leader keybindings for Lem vi-mode
;;;
;;; Mirrors Tom's Doom Emacs workflow:
;;;   - SPC-leader prefix tree (file, buffer, window, search, project, code, git, toggle)
;;;   - Custom overrides from config.el (SPC ; swapped with SPC :)
;;;   - vi-mode enabled by default

(in-package :lem-user)

;; === Enable vi-mode ===
(lem-vi-mode:vi-mode)

;; === Start REPL in insert mode ===
(add-hook lem-lisp-mode:*lisp-repl-mode-hook*
          'lem-vi-mode/commands:vi-insert)

;; === Leader Key System ===
;; Lem's vi-mode binds Space to vi-forward-char in the motion keymap.
;; We override it in normal keymap to act as our leader prefix.

;; Top-level leader keymap
(defvar *leader-keymap* (make-keymap :name "leader"))
(define-key lem-vi-mode:*normal-keymap* "Space" *leader-keymap*)

;; --- Top-level leader shortcuts ---
;; NOTE: SPC ; and SPC : are SWAPPED to match Tom's Doom config
(define-key *leader-keymap* ";" 'execute-command)           ; M-x (Doom: SPC :)
(define-key *leader-keymap* ":" 'lem-lisp-mode:lisp-eval-string) ; eval expression (Doom: SPC ;)
(define-key *leader-keymap* "." 'find-file)                 ; find file
(define-key *leader-keymap* "," 'select-buffer)             ; switch buffer
(define-key *leader-keymap* "`" 'switch-to-last-focused-window) ; last buffer (closest equivalent)
(define-key *leader-keymap* "/" 'project-grep)              ; search project
(define-key *leader-keymap* "Space" 'project-find-file)     ; find file in project
(define-key *leader-keymap* "u" 'lem/universal-argument:universal-argument) ; universal argument

;; ============================================================
;; SPC f — File operations
;; ============================================================
(defvar *leader-file-keymap* (make-keymap :name "file"))
(define-key *leader-keymap* "f" *leader-file-keymap*)

(define-key *leader-file-keymap* "f" 'find-file)            ; find file
(define-key *leader-file-keymap* "s" 'save-current-buffer)  ; save file
(define-key *leader-file-keymap* "S" 'save-some-buffers)    ; save all files
(define-key *leader-file-keymap* "r" 'find-recent-file)     ; recent files
(define-key *leader-file-keymap* "R" 'rename-buffer)        ; rename (buffer only, no file rename in Lem)
(define-key *leader-file-keymap* "l" 'find-file-recursively) ; locate/find file recursively
(define-key *leader-file-keymap* "y" 'current-directory)    ; yank/show current directory

;; ============================================================
;; SPC b — Buffer operations
;; ============================================================
(defvar *leader-buffer-keymap* (make-keymap :name "buffer"))
(define-key *leader-keymap* "b" *leader-buffer-keymap*)

(define-key *leader-buffer-keymap* "b" 'select-buffer)      ; switch buffer
(define-key *leader-buffer-keymap* "d" 'kill-buffer)        ; kill buffer
(define-key *leader-buffer-keymap* "k" 'kill-buffer)        ; kill buffer (alias)
(define-key *leader-buffer-keymap* "n" 'next-buffer)        ; next buffer
(define-key *leader-buffer-keymap* "p" 'previous-buffer)    ; previous buffer
(define-key *leader-buffer-keymap* "s" 'save-current-buffer) ; save buffer
(define-key *leader-buffer-keymap* "S" 'save-some-buffers)  ; save all buffers
(define-key *leader-buffer-keymap* "R" 'rename-buffer)      ; rename buffer
(define-key *leader-buffer-keymap* "r" 'revert-buffer)      ; revert buffer
(define-key *leader-buffer-keymap* "]" 'next-buffer)        ; next buffer
(define-key *leader-buffer-keymap* "[" 'previous-buffer)    ; previous buffer
;; NOTE: No "new empty buffer" (SPC b N) — Lem doesn't have a direct equivalent.
;;       Use :enew in ex mode or SPC ; → vi-switch-to-buffer

;; ============================================================
;; SPC w — Window operations
;; ============================================================
(defvar *leader-window-keymap* (make-keymap :name "window"))
(define-key *leader-keymap* "w" *leader-window-keymap*)

(define-key *leader-window-keymap* "v" 'split-active-window-horizontally)  ; vertical split (Doom/vim convention)
(define-key *leader-window-keymap* "s" 'split-active-window-vertically)    ; horizontal split
(define-key *leader-window-keymap* "d" 'delete-active-window)              ; delete window
(define-key *leader-window-keymap* "h" 'window-move-left)                  ; move to window left
(define-key *leader-window-keymap* "j" 'window-move-down)                  ; move to window below
(define-key *leader-window-keymap* "k" 'window-move-up)                    ; move to window above
(define-key *leader-window-keymap* "l" 'window-move-right)                 ; move to window right
(define-key *leader-window-keymap* "w" 'next-window)                       ; cycle windows
(define-key *leader-window-keymap* "o" 'delete-other-windows)              ; maximize (delete others)
(define-key *leader-window-keymap* "=" 'grow-window)                       ; grow window (no balance-windows in Lem)
;; NOTE: SPC w H/J/K/L (move window itself) — not available in Lem
;; NOTE: SPC w m (maximize toggle) — use SPC w o (delete-other-windows) instead, not toggleable

;; ============================================================
;; SPC s — Search
;; ============================================================
(defvar *leader-search-keymap* (make-keymap :name "search"))
(define-key *leader-keymap* "s" *leader-search-keymap*)

(define-key *leader-search-keymap* "s" 'isearch-forward)            ; search buffer
(define-key *leader-search-keymap* "b" 'isearch-forward)            ; search buffer (alias)
(define-key *leader-search-keymap* "r" 'query-replace)              ; search and replace
(define-key *leader-search-keymap* "R" 'query-replace-regexp)       ; search and replace (regex)
(define-key *leader-search-keymap* "p" 'project-grep)               ; search in project (ripgrep)
(define-key *leader-search-keymap* "d" 'grep)                       ; search in directory
(define-key *leader-search-keymap* "l" 'goto-line)                  ; jump to line
(define-key *leader-search-keymap* "h" 'isearch-toggle-highlighting) ; toggle search highlighting

;; ============================================================
;; SPC p — Project
;; ============================================================
(defvar *leader-project-keymap* (make-keymap :name "project"))
(define-key *leader-keymap* "p" *leader-project-keymap*)

(define-key *leader-project-keymap* "p" 'project-switch)            ; switch project
(define-key *leader-project-keymap* "f" 'project-find-file)         ; find file in project
(define-key *leader-project-keymap* "k" 'project-kill-buffers)      ; kill project buffers
(define-key *leader-project-keymap* "s" 'project-save)              ; save project
(define-key *leader-project-keymap* "/" 'project-grep)              ; grep in project
;; NOTE: SPC p b (switch to project buffer) — no project-scoped buffer switch in Lem

;; ============================================================
;; SPC c — Code / LSP
;; ============================================================
(defvar *leader-code-keymap* (make-keymap :name "code"))
(define-key *leader-keymap* "c" *leader-code-keymap*)

(define-key *leader-code-keymap* "d" 'find-definitions)             ; jump to definition
(define-key *leader-code-keymap* "D" 'find-references)              ; find references
(define-key *leader-code-keymap* "a" 'lsp-code-action)              ; code actions
(define-key *leader-code-keymap* "r" 'lsp-rename)                   ; rename symbol
(define-key *leader-code-keymap* "f" 'lsp-document-format)          ; format buffer
(define-key *leader-code-keymap* "k" 'lsp-hover)                    ; hover documentation
(define-key *leader-code-keymap* "i" 'lsp-implementation)           ; find implementations
(define-key *leader-code-keymap* "t" 'lsp-type-definition)          ; find type definition
(define-key *leader-code-keymap* "s" 'lsp-document-symbol)          ; list symbols
(define-key *leader-code-keymap* "o" 'lsp-organize-imports)         ; organize imports
(define-key *leader-code-keymap* "x" 'lsp-document-diagnostics)     ; list errors/diagnostics
(define-key *leader-code-keymap* "w" 'delete-trailing-whitespace)   ; delete trailing whitespace
(define-key *leader-code-keymap* "p" 'pop-definition-stack)         ; pop back from definition jump
;; NOTE: SPC c e (eval buffer/region) — use Lisp-mode eval commands instead
;; NOTE: SPC c c (compile) — no generic compile command in Lem

;; ============================================================
;; SPC g — Git (legit)
;; ============================================================
(defvar *leader-git-keymap* (make-keymap :name "git"))
(define-key *leader-keymap* "g" *leader-git-keymap*)

(define-key *leader-git-keymap* "g" 'legit-status)                  ; git status (magit equivalent)
(define-key *leader-git-keymap* "s" 'legit-status)                  ; git status (alias)
(define-key *leader-git-keymap* "c" 'legit-commit)                  ; commit
(define-key *leader-git-keymap* "b" 'legit-branch-checkout)         ; switch branch
(define-key *leader-git-keymap* "B" 'legit-branch-create)           ; create branch
(define-key *leader-git-keymap* "F" 'legit-pull)                    ; pull
(define-key *leader-git-keymap* "P" 'legit-push)                    ; push
(define-key *leader-git-keymap* "l" 'legit-commits-log)             ; log
(define-key *leader-git-keymap* "S" 'legit-stash-push)              ; stash
(define-key *leader-git-keymap* "U" 'legit-stash-pop)               ; stash pop
;; NOTE: Lem's legit is basic — no magit-level staging, blame, or forge integration

;; ============================================================
;; SPC h — Help
;; ============================================================
(defvar *leader-help-keymap* (make-keymap :name "help"))
(define-key *leader-keymap* "h" *leader-help-keymap*)

(define-key *leader-help-keymap* "k" 'describe-key)                 ; describe key
(define-key *leader-help-keymap* "b" 'describe-bindings)            ; describe all bindings
(define-key *leader-help-keymap* "m" 'describe-mode)                ; describe current mode
(define-key *leader-help-keymap* "a" 'apropos-command)              ; search commands
(define-key *leader-help-keymap* "h" 'help)                         ; general help
;; NOTE: SPC h f (describe function) — not available in Lem
;; NOTE: SPC h v (describe variable) — not available in Lem

;; ============================================================
;; SPC t — Toggles
;; ============================================================
(defvar *leader-toggle-keymap* (make-keymap :name "toggle"))
(define-key *leader-keymap* "t" *leader-toggle-keymap*)

(define-key *leader-toggle-keymap* "l" 'toggle-line-numbers)        ; toggle line numbers
(define-key *leader-toggle-keymap* "w" 'toggle-line-wrap)           ; toggle line wrapping
(define-key *leader-toggle-keymap* "r" 'toggle-read-only)           ; toggle read-only mode
(define-key *leader-toggle-keymap* "F" 'toggle-frame-fullscreen)    ; toggle fullscreen
(define-key *leader-toggle-keymap* "t" 'toggle-frame-multiplexer)   ; toggle tab bar
;; NOTE: SPC t z (zen mode) — not available in Lem
;; NOTE: SPC t f (flycheck/flymake) — no toggle, diagnostics always on with LSP

;; ============================================================
;; SPC TAB — Workspace / Tabs (frame-multiplexer)
;; ============================================================
(defvar *leader-tab-keymap* (make-keymap :name "tab"))
(define-key *leader-keymap* "Tab" *leader-tab-keymap*)

(define-key *leader-tab-keymap* "n" 'frame-multiplexer-create-with-new-buffer-list)  ; new workspace
(define-key *leader-tab-keymap* "d" 'frame-multiplexer-delete)       ; kill workspace
(define-key *leader-tab-keymap* "]" 'frame-multiplexer-next)         ; next workspace
(define-key *leader-tab-keymap* "[" 'frame-multiplexer-prev)         ; previous workspace
(define-key *leader-tab-keymap* "r" 'frame-multiplexer-rename)       ; rename workspace
(define-key *leader-tab-keymap* "Tab" 'frame-multiplexer-switch)     ; switch workspace
;; NOTE: SPC TAB 1-9 (switch to workspace N) — available via frame-multiplexer-switch-0 through 8
;;       but these are generated by a macro and may not be directly accessible

;; ============================================================
;; SPC o — Open
;; ============================================================
(defvar *leader-open-keymap* (make-keymap :name "open"))
(define-key *leader-keymap* "o" *leader-open-keymap*)

;; NOTE: SPC o t (terminal) — terminal.so not available in nix build
;; NOTE: SPC o r (REPL) — use Lisp-mode REPL commands (slime/sly)
;; NOTE: SPC o d (debugger) — not available in Lem
;; NOTE: SPC o - (dired) — Lem has directory-mode but no dired-jump equivalent

;; ============================================================
;; SPC q — Quit / Session
;; ============================================================
(defvar *leader-quit-keymap* (make-keymap :name "quit"))
(define-key *leader-keymap* "q" *leader-quit-keymap*)

(define-key *leader-quit-keymap* "q" 'exit-lem)                     ; quit
(define-key *leader-quit-keymap* "Q" 'quick-exit)                   ; quit without asking

;; ============================================================
;; SPC n — Notes (minimal — no org-mode in Lem)
;; ============================================================
;; NOTE: Lem has no org-mode. All SPC n bindings (agenda, capture, roam, journal)
;;       have no equivalent. This prefix is left empty for future custom commands.

;; ============================================================
;; SPC i — Insert
;; ============================================================
(defvar *leader-insert-keymap* (make-keymap :name "insert"))
(define-key *leader-keymap* "i" *leader-insert-keymap*)

(define-key *leader-insert-keymap* "f" 'insert-filename)            ; insert file path
(define-key *leader-insert-keymap* "u" 'quoted-insert)              ; insert special character

;; ============================================================
;; Additional normal-mode conveniences
;; ============================================================
;; gd — go to definition (common vim-LSP convention)
(define-key lem-vi-mode:*normal-keymap* "g d" 'find-definitions)
;; K — hover documentation (common vim-LSP convention)
(define-key lem-vi-mode:*normal-keymap* "K" 'lsp-hover)

;; ============================================================
;; UNMAPPED DOOM BINDINGS — Features not available in Lem
;; ============================================================
;;
;; SPC b N  — new empty buffer (no direct command; use :enew in ex mode)
;; SPC b O  — kill other buffers (no equivalent)
;; SPC b x  — scratch buffer (no scratch buffer system)
;; SPC b y  — yank buffer contents (no equivalent)
;; SPC b z  — bury buffer (no equivalent)
;;
;; SPC f C  — copy file (no equivalent)
;; SPC f D  — delete file (no equivalent)
;; SPC f u  — sudo find file (no equivalent)
;;
;; SPC w H/J/K/L — move window itself (not supported)
;; SPC w m  — maximize window toggle (not toggleable; use SPC w o)
;; SPC w =  — balance windows (not available)
;;
;; SPC s i  — jump to symbol (imenu) (no equivalent outside LSP)
;; SPC s o  — look up online (no equivalent)
;; SPC s u  — undo history tree (vundo) (no equivalent)
;;
;; SPC p b  — project buffer switch (no project-scoped buffer list)
;; SPC p c  — compile project (no generic compile)
;; SPC p r  — recent project files (no equivalent)
;; SPC p T  — test project (no equivalent)
;;
;; SPC n *  — entire notes prefix (no org-mode in Lem)
;;
;; SPC c e  — eval buffer/region (use lisp-mode eval for CL)
;; SPC c c  — compile (no generic compile command)
;; SPC c s  — send to REPL (use lisp-mode REPL interaction)
;;
;; SPC g .  — magit file dispatch (legit has no file-level dispatch)
;; SPC g B  — blame (no blame support in legit)
;; SPC g R  — vc-revert (no equivalent)
;; SPC g y  — copy link to remote (no equivalent)
;;
;; SPC h f  — describe function (no CL introspection from editor help)
;; SPC h v  — describe variable (no CL introspection from editor help)
;;
;; SPC t z  — zen mode (not available)
;; SPC t b  — big font mode (no equivalent)
;; SPC t s  — spell checker (not available)
;;
;; which-key — Lem has no which-key popup. Bindings work, but you
;;             don't get the discovery UI after pressing a prefix key.
