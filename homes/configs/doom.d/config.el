(add-to-list 'load-path (format "%s/elisp" (file-name-directory doom-user-dir)))

(use-package! 1password
  :demand t
  :config
  (1password-auth-source-enable))

(use-package! direnv
  :config
  (direnv-mode))

(setq doom-theme 'doom-zenburn)

(require 'shy-core)
(require 'shy-elfeed)
(require 'shy-erc)
(require 'shy-gnus)
(require 'shy-magit)
(require 'shy-org)
(require 'shy-tramp-mode)
