# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  users.users.dzr = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Dom Rodriguez";
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
    extraGroups = [
      "wheel"
      "dialout"
      "adbusers"
      "uucp"
      "kvm"
      "docker"
      "libvirt"
      "lp"
      "lpadmin"
      "plugdev"
      "input"
      "disk"
      "networkmanager"
      "video"
      "qemu-libvirtd"
      "libvirtd"
      "systemd-journal"
    ];
  };
}
