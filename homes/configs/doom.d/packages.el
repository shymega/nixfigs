;;; Copyright 2024 Google LLC
;;; SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

(package! evil-escape :disable t)
(package! w3m)
(package! erc-hl-nicks)
(package! dotenv-mode)
(package! 1password
  :recipe (:host github :repo "kamushadenes/1password.el" :files ("*.el"))
  :pin "d493405ef663654a497f9586788dfff7de26e9de")
(package! darkman
   :recipe (:host nil :repo "https://git.sr.ht/~grtcdr/darkman.el" :files ("*.el"))
   :pin "136eac628595c6777eb6b2246a014dfcb3b6c625")
(package! direnv)
(package! ement)
