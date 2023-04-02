{ config, pkgs, lib, ... }:

{
  boot = {
    cleanTmpDir = true;

    kernel.sysctl = { "vm.dirty_ratio" = 6; };
    supportedFilesystems = [ "ntfs" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=2
    '';

    kernelPackages = pkgs.linuxPackages_xanmod;

    kernelParams = [ "quiet" ];

    initrd.luks.devices = {
      os = {
        device = "/dev/disk/by-uuid/edcd0e99-5d70-4eb1-98d2-354b0bb4a3ab";
        preLVM = true;
        allowDiscards = true;
      };
    };

    loader = {
      systemd-boot = { enable = true; };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 3;
    };
  };
}
