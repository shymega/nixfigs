# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      enable = true;
      libinput.enable = true;
      desktopManager = { plasma5.enable = true; };
      windowManager = {
        stumpwm.enable = true;
        i3.enable = true;
      };
      layout = "us";
    };
  };

  services.xserver.displayManager.startx.enable = true;
}
