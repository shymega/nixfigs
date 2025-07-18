# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{ pkgs, ... }:
{
  programs.sway = {
    enable = true;
    package = pkgs.sway;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      alacritty
      clipman
      grim
      kanshi
      mako
      slurp
      slurp
      sway-contrib.grimshot
      swayidle
      swaylock
      waybar
      waybar
      wayland
      wdisplays
      wf-recorder
      wl-clipboard
      wofi
      xdg-utils
    ];
    extraSessionCommands = ''
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export SDL_VIDEODRIVER=wayland
      export SSH_ASKPASS==${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass
      export SUDO_ASKPASS=${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };
}
