# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:

{
  boot = {
    initrd.availableKernelModules =
      [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "hid_apple" ];
    initrd.kernelModules = [ "dm-snapshot" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    resumeDevice = "/dev/disk/by-label/SWAP";
  };

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  fileSystems =
    {
      "/" =
        {
          device = "tank/local/root";
          fsType = "zfs";
        };

      "/nix" =
        {
          device = "tank/local/nix";
          neededForBoot = true; # required
          fsType = "zfs";
        };

      "/persist" =
        {
          device = "tank/safe/persist";
          neededForBoot = true; # required
          fsType = "zfs";
        };

      "/var/log" =
        {
          device = "tank/safe/log";
          neededForBoot = true; # required
          fsType = "zfs";
        };

      "/etc/nixos" =
        {
          device = "tank/safe/nixos-config";
          neededForBoot = true; # required
          fsType = "zfs";
        };

      "/boot" = {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
        neededForBoot = true; # required
      };

      "/home" = {
        device = "/dev/disk/by-label/HOME";
        fsType = "xfs";
      };

    };

  swapDevices = [{ device = "/dev/disk/by-label/SWAP"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
