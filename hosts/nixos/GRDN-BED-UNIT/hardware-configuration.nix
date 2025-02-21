# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ config, pkgs, lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd.availableKernelModules = lib.mkForce [
      "usbhid"
      "usb_storage"
      "vc4"
      "pcie_brcmstb" # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
    ];
    supportedFilesystems = [ "zfs" ];

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

    initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      after = [
        "zfs-import-tank.service"
      ];
      before = [
        "sysroot.mount"
      ];
      path = with pkgs; [
        zfs
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r tank/local/root@blank
      '';
    };
  };

  fileSystems = {
    "/" =
      {
        device = "tank/local/root";
        fsType = "zfs";
      };

    "/boot" =
      {
        device = "/dev/disk/by-label/EFI";
        fsType = "vfat";
        neededForBoot = true;
      };

    "/firmware" =
      {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [ "ro" "nofail" ];
        neededForBoot = true;
      };

    "/nix" =
      {
        device = "tank/local/nix";
        fsType = "zfs";
        neededForBoot = true;
      };

    "/etc/nixos" =
      {
        device = "tank/safe/nixos-config";
        fsType = "zfs";
        neededForBoot = true;
      };

    "/persist" =
      {
        device = "tank/safe/persist";
        fsType = "zfs";
        neededForBoot = true;
      };
  };
}
