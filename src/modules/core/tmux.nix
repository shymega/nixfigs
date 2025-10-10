# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{lib, ...}: let
  inherit (lib) isDarwin isNixOS isLinux;
in {
  programs = {
    tmux = {
      enable = true;
      shortcut = lib.mkDefault "b";
      aggressiveResize = (isNixOS || isLinux) && !isDarwin;
      baseIndex = 0;
      keyMode = "emacs";
      newSession = false;
      terminal = "tmux-256color";
      escapeTime = 0;
      secureSocket = false; # FIXME: Force tmux to use /tmp for sockets (WSL2 compat)

      extraConfig = ''
        # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        set-environment -g COLORTERM "truecolor"

        # easy-to-remember split pane commands
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        bind-key -n Home send Escape "OH"
        bind-key -n End send Escape "OF"
        set -g window-status-format "[#I:#W(#(ps -o tpgid:1= -p #{pane_pid}),#{pane_current_path})#F]"
        set -g window-status-current-format "[#I:#W(#(ps -o tpgid:1= -p #{pane_pid}),#{pane_current_path})#F]"
      '';

      clock24 = true;
      historyLimit = 10000;
    };
  };
}
