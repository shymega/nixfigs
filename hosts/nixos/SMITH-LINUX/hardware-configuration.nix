# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ lib, modulesPath, ... }:
{
  boot = {
    initrd.availableKernelModules = lib.mkForce [
      "usbhid"
      "usb_storage"
      "vc4"
      "pcie_brcmstb" # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
    ];

    kernelParams = lib.mkAfter [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      "cma=128M"
      "kunit.enable=0"
    ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
      systemd-boot.enable = true;
    };

  };

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
        neededForBoot = true;
      };
    "/boot" =
      {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
        neededForBoot = true;
      };
    "/firmware" =
      {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [ "ro" "nofail" ];
        neededForBoot = false;
      };
  };
}
