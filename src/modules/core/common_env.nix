# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{pkgs, ...}: {
  environment = {
    variables = {
      TERMINAL = "${pkgs.lib.getExe pkgs.alacritty}";
      EDITOR = pkgs.lib.mkForce "${pkgs.lib.getExe' pkgs.emacs "emacsclient"}";
      VISUAL = "$EDITOR";
      GIT_EDITOR = "$EDITOR";
      SUDO_EDITOR = "$EDITOR";
    };
  };
}
