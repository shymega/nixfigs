{ config, pkgs, lib, ... }:
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
      sway-contrib.grimshot
      swayidle
      swaylock
      waybar
      wdisplays
      wf-recorder
      wl-clipboard
      wofi
      waybar
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };
}
