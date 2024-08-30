;;; gnus.el --- GNUS configuration for Emacs
;;; commentary:
;;; code:

(setq gnus-save-newsrc-file t)
(setq gnus-read-newsrc-file t)

(use-package! w3m
  :ensure t)

(defvar gnus-select-method nil)

(defvar gnus-secondary-select-methods
  '((nnimap "dominic.rodriguez@rodriguez.org.uk"
     (nnimap-stream network)
     (nnimap-address "localhost")
     (nnir-search-engine imap)
     (nnimap-user "dominic.rodriguez@rodriguez.org.uk"))
    (nnimap "shymega@shymega.org.uk"
            (nnimap-stream network)
            (nnimap-address "localhost")
            (nnir-search-engine imap)
            (nnimap-user "shymega@shymega.org.uk"))
    (nntp "localhost"
          (nntp-address "localhost")
          (nntp-port-number 1119))
  (nnimap "rnet@rodriguez.org.uk"
          (nnimap-stream network)
          (nnimap-address "localhost")
          (nnir-search-engine imap)
          (nnimap-user "rnet@rodriguez.org.uk"))))

(defvar mm-text-html-renderer 'w3m)

(defvar gnus-use-cache t)

(defun get-sig-from-mutt (acc)
  "Return account's signature specifed by ACC in $HOME/.mutt/accounts/%s.sig."
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name (format "%s/.config/neomutt/conf.d/accounts.d//%s.sig"
                               (getenv "HOME") acc)))
    (buffer-string)))

(defvar gnus-posting-styles
  '(("dominic.rodriguez@rodriguez.org.uk"
     (signature (get-sig-from-mutt "dominic.rodriguez@rodriguez.org.uk"))
     (name "Dom Rodriguez")
     (address "dominic.rodriguez@rodriguez.org.uk"))
    ("rnet@rodriguez.org.uk"
     (signature (get-sig-from-mutt "rnet@rodriguez.org.uk"))
     (name "RNET Administrators")
     (address "rnet@rodriguez.org.uk"))
    ("shymega@shymega.org.uk"
     (signature (get-sig-from-mutt "shymega@shymega.org.uk"))
     (name "Dom Rodriguez")
     (address "shymega@shymega.org.uk"))
    ("nntp-oss"
     (signature (get-sig-from-mutt "shymega@shymega.org.uk"))
     (name "Dom Rodriguez")
     (address "shymega@shymega.org.uk"))))

(defvar mm-discouraged-alternatives '("text/html" "text/richtext"))

(defvar gnus-read-active-file 'some)

(defvar gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject)

(defvar gnus-thread-hide-subtree t)
(defvar gnus-thread-ignore-subject t)

(defvar gnus-use-correct-string-widths nil)

(defvar gnus-thread-sort-functions
  '((not gnus-thread-sort-by-date)
    (not gnus-thread-sort-by-number)))

;;; send emails with msmtp-enqueue
;;; I've set up a script to perform checks on the queue and deal with them as needed, depending on connectivity.

(setq message-send-mail-function 'message-send-mail-with-sendmail
      mail-specify-envelope-from t
      message-sendmail-f-is-evil nil
      mail-envelope-from 'header
      message-sendmail-envelope-from 'header)

(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

(defvar gnus-topic-topology '(("Gnus" visible)
                              (("dominic.rodriguez@rodriguez.org.uk" visible nil nil))
                              (("shymega@shymega.org.uk" visible nil nil))
                              (("rnet@rodriguez.org.uk" visible nil nil))))
(defvar gnus-topic-alist '(
                           ("dominic.rodriguez@rodriguez.org.uk"
                            "nnimap+dominic.rodriguez:INBOX"
                            "nnimap+dominic.rodriguez:INBOX")
                           ("shymega@shymega.org.uk"
                            "nnimap+shymega:INBOX"
                            "nnimap+shymega:INBOX")
                           ("rnet@rodriguez.org.uk"
                            "nnimap+rnet:INBOX"
                            "nnimap+rnet:INBOX")
                           ("Gnus")))

(defun start-gnus ()
  "Start GNUS with demon handlers."
  (interactive)
  (gnus))

(provide 'shy-gnus)
;;; gnus.el ends here
