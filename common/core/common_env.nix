# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, outputs, pkgs, ... }: {
  environment = {
    variables = {
      TERMINAL = "${pkgs.alacritty}/bin/alacritty";
      EDITOR = "${pkgs.emacs}/bin/emacsclient -c";
      VISUAL = "$EDITOR";
      GIT_EDITOR = "$EDITOR";
      SUDO_EDITOR = "$EDITOR";
    };
  };
}
