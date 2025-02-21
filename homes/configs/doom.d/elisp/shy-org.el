;;; org.el --- org-mode configuration
;;
;;; commentary:
;;; configuration for org-mode in my Emacs.
;;;
;;; code:

;;; require org-mode
(use-package! org :ensure t)

;;; require org-mode (REVEAL.JS)
(use-package! ox-reveal :ensure t)

;;; org-mode handle .org files
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

;;; define key-bindings, right now dammnit
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-cc" 'org-capture)
(define-key global-map "\C-cb" 'org-iswitchb)
(define-key global-map "\C-ca" 'org-agenda)

;;; todo items get marked with timestampt when done
(defvar org-log-done 'time)

;;; on the tin
(setq org-enforce-todo-dependencies t)

;;; show in reverse, easier, yes beliebve me
(setq org-reverse-note-order t)

;;; don't dim blocked tasks (dependencies) pls
(defvar org-agenda-dim-blocked-tasks nil)

(setq
 org-agenda-skip-deadline-if-done t
 org-agenda-skip-deadline-prewarning-if-scheduled t
 org-agenda-skip-scheduled-if-done t
 org-agenda-skip-timestamp-if-done t
 org-agenda-start-on-weekday 1
 org-return-follows-link t
 org-agenda-file-regexp "\\.org\\'")

(setq org-agenda-custom-commands'(
                                  ("w" todo "WAITING" nil)
                                  ("n" todo "NEXT" nil)
                                  ("d" "Agenda + Next Actions" ((agenda) (todo "NEXT")))))

(defun gtd ()
  "This function open ~/Documents/org/todo/gtd.org."
  (interactive)
  (find-file "~/Documents/org/todo/gtd.org"))

(defvar org-directory (expand-file-name "~/org/"))

(setq diary-file "~/.diary")
(setq org-agenda-diary-file "~/org/diary.org")

(defvar org-startup-truncated t)

(setq org-hide-leading-stars t)

(defvar org-icalendar-timezone "Europe/London")

(setq
 org-agenda-span 2
 org-agenda-tags-column -100
 org-agenda-sticky nil
 org-agenda-inhibit-startup t
 org-agenda-use-tag-inheritance t
 org-agenda-show-log t
 org-agenda-skip-scheduled-if-done t
 org-agenda-skip-deadline-if-done t
 org-agenda-skip-deadline-prewarning-if-scheduled 'pre-scheduled
 org-agenda-time-grid '((daily today require-timed)
                        "----------------"
                        (800 1000 1200 1400 1600 1800)))

(appt-activate t)

(setq
 appt-message-warning-time 120
 appt-display-mode-line t
 appt-display-interval 10
 appt-audible nil
 appt-display-format 'nil)

(appt-activate 1)
(display-time)
(org-agenda-to-appt)

(require 'midnight)
(setq midnight-mode t)

(add-hook 'midnight-hook 'org-agenda-to-appt)
(add-hook 'midnight-hook 'org-mobile-push)

(add-hook 'org-finalize-agenda-hook 'org-agenda-to-appt)

(require 'notifications)

(defun my-appt-disp-window-function (min-to-app new-time msg)
  (notifications-notify
   :title (format "Appointment in %s min!" min-to-app)
   :body msg
   :app-name "Emacs"))

(setq appt-disp-window-function 'my-appt-disp-window-function)
(setq appt-delete-window-function (lambda (&rest args)))

(provide 'shy-org)
;;; org.el ends here
