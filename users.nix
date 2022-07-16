# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  users.users.dzr = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Dom Rodriguez";
    extraGroups = [
      "wheel"
      "dialout"
      "adbusers"
      "uucp"
      "kvm"
      "docker"
      "lp"
      "disk"
      "networkmanager"
      "video"
      "systemd-journal"
    ];
  };
}
