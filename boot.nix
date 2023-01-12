# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  boot = {
    cleanTmpDir = true;

    kernel.sysctl = { "vm.dirty_ratio" = 6; };
    supportedFilesystems = [ "ntfs" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';

    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelPackages = pkgs.linuxPackages_6_0;

    kernelParams = [ "quiet" ];

    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/edcd0e99-5d70-4eb1-98d2-354b0bb4a3ab";
        preLVM = true;
        allowDiscards = true;
      };
    };

    loader = {
      systemd-boot = { enable = true; };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };
  };
}
