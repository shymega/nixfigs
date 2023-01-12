# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, callPackage, lib, ... }:

{
  networking = {
    networkmanager = { plugins = [ pkgs.networkmanager-openvpn ]; };
  };

  nixpkgs.config = {
    allowBroken = false;
    android_sdk.accept_license = true;
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    gnupg
    pinentry-gnome
    pinentry-gtk2
    pinentry_qt5
    pinentry-rofi
    pinentry-curses
    pinentry
    xorg.xinit
    htop
    bc
    acpi
    openvpn
    tmux
    nix-index
    ryzenadj
    git
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-rtsp-server
    gst_all_1.gstreamer
    gst_all_1.gst-libav
    modem-manager-gui
  ];
}
