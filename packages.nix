# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  networking = {
    networkmanager = { plugins = [ pkgs.networkmanager-openvpn ]; };
  };

  fonts.fonts = with pkgs; [
    open-dyslexic
    fira
    fira-code
    font-awesome_5
    font-awesome_4
    noto-fonts
    noto-fonts-emoji
    emojione
    twemoji-color-font
  ];

  nixpkgs.config = {
    allowBroken = false;
    android_sdk.accept_license = true;
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs;
    with qt5;
    with libsForQt5;
    with plasma5;
    with kdeApplications; [
      gnupg
      pinentry
      acpi
      openvpn
      tmux
      pavucontrol
    ];
}
