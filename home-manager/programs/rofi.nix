{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  originalConfig = config;
in (lib.mkIf isLinux {

  programs.rofi = {
    enable = true;
    font = "IBM Plex Mono";
    extraConfig = { dpi = 0; };
    plugins = with pkgs; [ rofi-emoji ];
    cycle = true;
    pass.enable = true;
  };
})
