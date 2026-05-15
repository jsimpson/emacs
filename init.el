;; -*- lexical-binding: t; -*-

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

(load (expand-file-name "secrets.el" user-emacs-directory) t)

;; silence Emacs 30.2 compiler/warning buffers
(setq native-comp-async-report-warnings-errors 'silent)
(setq byte-compile-warnings '(not free-vars unresolved last-line obsolete))
(setq warning-minimum-level :error)

;; packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq my-packages '(evil
                    evil-collection
                    evil-org
                    general
                    doom-themes
                    doom-modeline
                    racket-mode
                    paredit
                    rainbow-delimiters
                    magit
                    which-key
                    projectile))

;; automatic installation
(unless package-archive-contents
  (package-refresh-contents))
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-install pkg)))

;; org
(require 'org)
(setq org-ellipsis " ▾"
      org-hide-emphasis-markers t
      org-log-done 'time)

(setq org-directory "~/notes"
      org-default-notes-file (expand-file-name "inbox.org" org-directory))

(unless (file-exists-p org-directory)
  (make-directory org-directory))

(add-hook 'org-mode-hook 'visual-line-mode)

(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-confirm-babel-evaluate nil)

;; evil
(require 'evil)
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(evil-mode 1)

(with-eval-after-load 'evil
  (require 'evil-collection)
  (evil-collection-init)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line))

(with-eval-after-load 'org
  (require 'evil-org)
  (add-hook 'org-mode-hook 'evil-org-mode)
  (evil-org-set-key-theme '(navigation insert shift todo heading)))

;; escape should quit everything
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; autocomplete
(global-completion-preview-mode 1)

(setq completions-format 'one-column)
(setq completions-max-height 20)
(setq completion-auto-select t)

;; ui & theme
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode t)

;; theme & modeline
(load-theme 'doom-tokyo-night t)
(require 'doom-modeline)
(doom-modeline-mode 1)

;; font
(set-face-attribute 'default nil :font "JetBrains Mono" :height 125)

;; relative line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode t)
(dolist (mode '(term-mode-hook shell-mode-hook eshell-mode-hook racket-repl-mode-hook treemacs-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; editor hygiene
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq sentence-end-double-space nil)

;; backups & auto-saves
(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory))))
(setq auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save" user-emacs-directory) t)))
(setq backup-by-copying t)
(setq create-lockfiles nil)

;; paren management
(setq show-paren-delay 0)
(show-paren-mode 1)

;; lisp & racket dev
(require 'racket-mode)
(add-hook 'racket-mode-hook #'racket-xp-mode)
(add-hook 'racket-mode-hook #'enable-paredit-mode)
(add-hook 'racket-mode-hook #'rainbow-delimiters-mode)

;; REPL hygiene
(add-hook 'racket-repl-mode-hook #'enable-paredit-mode)

;; global lisp structural editing
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)

;; utils
(require 'which-key)
(setq which-key-idle-delay 0.3)
(which-key-mode)

;; start the server for emacsclient use
(require 'server)
(unless (server-running-p)
  (server-start))

(require 'projectile)
(setq projectile-project-search-path '("~/projects" "~/.config/emacs/"))
(setq projectile-completion-system 'default)
(setq projectile-git-command "fdfine . -0 --type f")
(projectile-mode +1)

(require 'general)

;; use SPC in normal/visual/motion states
(general-create-definer jsi/leader-keys
   :states '(normal visual motion emacs)
   :keymaps 'override
   :prefix "SPC"
   :global-prefix "C-SPC")

(defun jsi/save-and-eval-buffer ()
  "Save the current buffer and then eval it."
  (interactive)
  (save-buffer)
  (eval-buffer)
  (message "Buffer saved and eval'd."))

(jsi/leader-keys
  "." '(find-file :which-key "find file")
  "b" '(:ignore t :which-key "buffer")
  "bb" '(switch-to-buffer :which-keyu "switch buffer")
  "bk" '(kill-current-buffer :which-key "kill buffer")

  "e" '(:ignore t :which-key "eval")
  "eb" '(eval-buffer :which-key "eval buffer")
  "ee" '(eval-last-sexp :which-key "eval last expression")
  "ef" '(eval-defun :which-key "eval fun/defun")
  "er" '(eval-region :which-key "eval region")
  "es" '(jsi/save-and-eval-buffer :which-key "save and eval buffer")

  "f" '(:ignore t :which-key "file")
  "fp" '((lambda () (interactive) (find-file (expand-file-name "init.el" user-emacs-directory))) :which-key "open init.el")
  "fs" '(save-buffer :which-key "save file")

  "g" '(:ignore t :which-key "magit")
  "gg" '(magit-status :which-key "magit status")
  "gb" '(magit-blame-addition :which-key "magit blame")
  "gl" '(magit-log-current :which-key "magit log")
  "gd" '(magit-diff-buffer-file :which-key "magit diff current file")
  "gf" '(magit-find-file :which-key "magit find file")

  "n" '(:ignore t :which-key "notes")
  "na" '(org-agenda :which-key "agenda")
  "nc" '(org-capture :which-key "capture")
  "ni" '((lambda () (interactive) (find-file (expand-file-name "inbox.org" org-directory))) :which-key "open inbox")
  "nt" '(org-todo :which-key "cycle todo state")

  "p" '(:ignore t :which-key "project")
  "pp" '(projectile-switch-project :which-key "switch project")
  "pf" '(projectile-find-file :which-key "find file in project")
  "ps" '(projectile-save-project-buffers :which-key "save project")
  "pd" '(projectile-dired :which-key "project dired")

  "q" '(:ignore t :which-key "quit")
  "qq" '(save-buffers-kill-terminal :which-key "quit emacs"))
