# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:

{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "hid_apple"
    ];
    initrd.kernelModules = [ "i915" ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    resumeDevice = "/dev/disk/by-label/SWAP";
  };

  fileSystems = {
    "/" =
      {
        device = "tank/local/root";
        fsType = "zfs";
      };

    "/nix" =
      {
        device = "tank/safe/nix-store";
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

    "/data" = {
      device = "/dev/disk/by-label/SHARED";
      fsType = "btrfs";
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
