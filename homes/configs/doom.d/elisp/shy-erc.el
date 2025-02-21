;;; erc.el --- ERC configuration for GNU Emacs
;;; Commentary:
;;; Code:

;;; Got to give credit here, I got a lot of inspiration for the next section (marked by {{{ and }}}) from qdot's Emacs configuration. Kudos to you, man, nice LISP. {{{

(require 'erc)
(require 'erc-fill)
(require 'erc-ring)
(require 'erc-match)

(defvar erc-max-buffer-size 50000)
(defvar erc-truncate-buffer-on-save t)

(with-eval-after-load 'erc-track
  (setq erc-track-faces-priority-list
	(remq 'erc-notice-face erc-track-faces-priority-list)))


(setq
  erc-kill-buffer-on-part t
  erc-prompt (lambda () (concat (buffer-name) ">"))
  erc-prompt-for-password nil
  erc-server-reconnect-attempts 3
  erc-server-reconnect-timeout 30
  erc-track-exclude-server-buffer t
  erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT")
  erc-auto-query 'bury
  erc-button-url-regexp "\\([-a-zA-Z0-9_=!?#$@~`%&*+\\/:;,]+\\.\\)+[-a-zA-Z0-9_=!?#$@~`%&*+\\/:;,]*[-a-zA-Z0-9\\/]"
  erc-current-nick-highlight-type 'nick
  erc-fill-column 80
  erc-fill-function 'erc-fill-static
  erc-fill-prefix "      "
  erc-fill-static-center 0
  erc-fill-static-center 20
  erc-insert-timestamp-function 'erc-insert-timestamp-left
  erc-interpret-mirc-color t
  erc-join-buffer 'bury
  erc-keywords nil
  erc-kill-queries-on-quit nil
  erc-lurker-hide-list '("JOIN" "PART" "QUIT")
  erc-rename-buffers t
  erc-timestamp-format "[%H:%M] "
  erc-timestamp-only-if-changed-flag nil
  erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE" "324" "329" "332" "333" "353" "477")
  erc-track-faces-priority-list '(erc-current-nick-face erc-keyword-face)
  erc-track-priority-faces-only 'all
  erc-track-use-faces t
  erc-track-exclude-types '("JOIN" "NICK" "QUIT" "MODE"))

(defun shymega/erc-mode-hook ()
  "Set up ERC, hook."
  (setq blink-matching-paren nil)
  (erc-spelling-mode nil)
  (setq completion-auto-help 'lazy))

(add-hook 'erc-mode-hook 'shymega/erc-mode-hook)

(add-hook 'erc-insert-post-hook 'erc-truncate-buffer)

(defun get-chat-sr-ht-pw ()
  (1password-get-field "Sourcehut BNC" "credential"))

(defun get-chat-sr-ht-user (network)
  (format "shymega/%s@%s" network
          (system-name)))

(setq erc-networks '("Libera" "OFTC" "IRCnet" "AAnet" "Pine64"))

(defun run-erc ()
  (interactive)
  (dolist (network erc-networks)
    (let ((erc-sasl-auth-source-function #'erc-auth-source-search))
    (erc-tls :server "chat.sr.ht"
             :port "6697"
             :nick "shymega"
             :user (get-chat-sr-ht-user network)
             :password (get-chat-sr-ht-pw)))))

(use-package erc-hl-nicks
  :ensure t
  :after erc
  :config
  (add-to-list 'erc-modules 'hl-nicks))

(setopt erc-modules '(autoaway
                       autojoin
                      button
                      completion
                      fill
                      irccontrols
                      keep-place
                      list
                      match
                      menu
                      move-to-prompt
                      netsplit
                      networks
                      noncommands
                      readonly
                      ring
                      scrolltobottom
                      stamp
                      track
                      track))
(erc-update-modules)

(defun shymega/erc-znc-rename-server-buffer ()
  "This function prefixes the server buffer with 'znc'."
  (interactive)
  (save-excursion
    (let ((network-name (symbol-name (erc-network))))
      (set-buffer (erc-server-buffer))
      (rename-buffer (concat "znc-" (downcase network-name)))
      (message (format "Renamed buffer to %s" network-name)))))

(defun shymega/erc-znc-initalize (server nick)
  "This function takes the name of the SERVER, the NICK, and renames the buffer to have a 'znc-' prefix."
  (shymega/erc-znc-rename-server-buffer))

(add-hook 'erc-after-connect 'shymega/erc-znc-initalize)

(run-erc)

(provide 'shy-erc)
