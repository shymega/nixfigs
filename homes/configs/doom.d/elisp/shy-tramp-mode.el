;;; tramp-mode.el --- TRAMP-mode
;;; commentary:
;;; code:

(require 'tramp)

(setq tramp-default-method "ssh")

(defvar tramp-default-method-alist '("localhost" "" "sudo"))

(setq tramp-backup-directory-alist backup-directory-alist)

(defvar tramp-default-proxies-alist
             '(nil "\\`root\\'" "/ssh:%h:"))

(add-to-list 'tramp-default-proxies-alist
             '((regexp-quote (system-name)) nil nil))

(provide 'shy-tramp-mode)
;;; tramp-mode.el ends here
