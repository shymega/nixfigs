(use-package! 1password
  :demand t
  :config
  (1password-auth-source-enable))

(use-package! direnv
 :config
 (direnv-mode))

(setq doom-theme 'doom-zenburn)

(defun get-chat-sr-ht-pw ()
  (1password-get-field "Sourcehut BNC" "credential"))

(defun get-erc-userid (network)
  (format "shymega/%s@%s" network
          (system-name)))

(setq erc-networks ("Libera" "OFTC" "IRCnet" "AAnet" "Pine64"))

(defun run-erc ()
  (interactive)
  (dolist (network erc-networks)
    (erc-tls :server "chat.sr.ht"
             :port 6697
             :nick (get-erc-userid network)
             :password (get-chat-sr-ht-pw))))

(use-package! darkman)
(use-package! ement)

(setopt erc-auto-query 'bury
        erc-join-buffer 'bury
        erc-interpret-mirc-color t
        erc-rename-buffers t
        erc-lurker-hide-list '("JOIN" "PART" "QUIT")
        erc-track-exclude-types '("JOIN" "NICK" "QUIT" "MODE")
        erc-fill-column 80
        erc-fill-function 'erc-fill-static
        erc-fill-static-center 20)

(use-package erc-hl-nicks :after erc)

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
                      hl-nicks))
(erc-update-modules)
