# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  services = {
    flatpak.enable = true;
    thermald.enable = true;
    dbus.enable = true;
    openssh = {
      enable = true;
      startWhenNeeded = true;
    };
    udisks2 = { enable = true; };
    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };
    avahi = { enable = true; };
    blueman.enable = true;
#    zerotierone.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    power-profiles-daemon.enable = false;
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  hardware.usbWwan.enable = true;
}
