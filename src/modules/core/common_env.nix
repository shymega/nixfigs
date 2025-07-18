# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{pkgs, ...}: {
  environment = {
    variables = {
      TERMINAL = "${pkgs.lib.getExe pkgs.alacritty}";
      EDITOR = "${pkgs.lib.getExe' pkgs.emacs "emacsclient"}";
      VISUAL = "$EDITOR";
      GIT_EDITOR = "$EDITOR";
      SUDO_EDITOR = "$EDITOR";
    };
  };
}
