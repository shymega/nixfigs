(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

(setq delete-old-versions -1)

(setq version-control t)

(setq vc-make-backup-files t)

(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

(setq
 x-select-enable-clipboard t
 x-select-enable-primary nil
 save-interprogram-paste-before-kill nil
 interprogram-paste-function 'x-cut-buffer-or-selection-value)

(add-to-list 'auto-mode-alist '("\\.log\\'" . auto-revert-mode))

(setq scroll-margin 5
      scroll-preserve-screen-position 1)

(setq-default frame-title-format '((:eval (if (buffer-file-name)
                                              (abbreviate-file-name (buffer-file-name)) "%f"))))

(setq
 confirm-kill-emacs 'yes-or-no-p
 large-file-warning-threshold nil)

(global-auto-revert-mode 1)

(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)

(setq-default line-spacing 1)

(show-paren-mode 1)

(when (equal window-system "x")
    (setq browse-url-browser-function 'browse-url-firefox))

(defvar linum-format "%d ")

(setq split-height-threshold 0)
(setq split-width-threshold nil)

(set-fringe-mode '(10 . 0))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(setq-default c-basic-offset 2)

(setq visible-bell nil)

(setq ring-bell-function (lambda ()
                           (message "*beep*")))

(setq scroll-error-top-bottom t)
(setq byte-compile-debug t)
(require 'elp)
(setq elp-sort-by-function 'elp-sort-by-average-time)

(setq
 kill-ring-max 120
 kill-whole-line t
 kill-read-only-ok t)

(setq sentence-end-double-space t)
(setq require-final-newline t)

(setq next-screen-context-lines 0)

(setq
 enable-local-eval t
 enable-local-variables t)

(electric-pair-mode 1)

(show-paren-mode 1)
(display-time-mode 1)
(auto-compression-mode t)

(blink-cursor-mode -1)

(add-to-list 'exec-path (expand-file-name "~/.bin/"))

(defvar savehist-file "~/.emacs.d/savehist")

(savehist-mode 1)

(defvar history-length t)

(defvar history-delete-duplicates t)

(defvar savehist-save-minibuffer-history 1)

(defvar savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq org-export-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)

(setq initial-major-mode 'lisp-interaction-mode)

(with-current-buffer "*scratch*"
  (if (not (eq major-mode initial-major-mode))
      (funcall initial-major-mode)))

(setq initial-scratch-message
      (purecopy "
;;; Scratch!
;;; --------
;;;; This buffer is for notes you don't want to save, etc.
"))

(defun recreate-scratch-buffer ()
  "This function recreate *scratch* buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode))

(when (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      (tooltip-mode -1)
      (menu-bar-mode -1)))

(unless (display-graphic-p)
    (progn
      (tool-bar-mode -1)
      (tooltip-mode -1)
      (menu-bar-mode -1)))

(setq user-full-name "Dom Rodriguez"
      user-mail-address "shymega@shymega.org.uk")

(provide 'shy-core)
