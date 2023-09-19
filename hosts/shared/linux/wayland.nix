{ config, pkgs, lib, ... }:
{
  programs.sway = {
    enable = true;
    package = pkgs.sway;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      unstable.alacritty
      clipman
      grim
      unstable.kanshi
      mako
      slurp
      sway-contrib.grimshot
      swayidle
      swaylock
      unstable.waybar
      wdisplays
      wf-recorder
      wl-clipboard
      wofi
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };

  programs.waybar.enable = true;
}
