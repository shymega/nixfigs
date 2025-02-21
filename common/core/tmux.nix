# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ lib, ... }:
let
  inherit (lib.my) isDarwin isNixOS isLinux;
in
{
  programs.tmux = {
    enable = true;
    shortcut = lib.mkDefault "b";
    aggressiveResize = (isNixOS || isLinux) && !isDarwin;
    baseIndex = 0;
    keyMode = "emacs";
    secureSocket = false; # Force tmux to use /tmp for sockets (WSL2 compat)

    extraConfig = ''
      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';

    clock24 = true;
    historyLimit = 10000;
  };
}
