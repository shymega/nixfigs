# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  boot.zfs.requestEncryptionCredentials = true;

  fileSystems = {
    "/" =
      {
        device = "zosroot/crypt/nixos/local/root";
        fsType = "zfs";
      };

    "/data/Games" =
      {
        device = "zdata/shared/games";
        fsType = "zfs";
        neededForBoot = false;
      };

    "/data/AI" =
      {
        device = "zdata/shared/ai";
        fsType = "zfs";
        neededForBoot = false;
      };

    "/data/VMs" =
      {
        device = "zdata/shared/virtual";
        fsType = "zfs";
        neededForBoot = false;
      };

    "/home" =
      {
        device = "zdata/shared/home-nixos";
        fsType = "zfs";
        neededForBoot = false;
      };

    "/etc/nixos" =
      {
        device = "zosroot/crypt/nixos/safe/nixos-config";
        fsType = "zfs";
        neededForBoot = true;
      };

    "/nix" =
      {
        device = "zosroot/crypt/nixos/local/nixos-store";
        fsType = "zfs";
        neededForBoot = true;
      };

    "/persist" =
      {
        device = "zosroot/crypt/nixos/safe/persist";
        fsType = "zfs";
        neededForBoot = true;
      };

    "/var" =
      {
        device = "zosroot/crypt/nixos/safe/var-store";
        fsType = "zfs";
        neededForBoot = true;
      };

    "/home/dominic.rodriguez/.local/share/atuin" =
      {
        device = "/dev/disk/by-label/ATUIN_NIXOS";
        fsType = "ext4";
      };

    "/boot/efi/BAZZITE" =
      {
        device = "/dev/disk/by-label/ESP_BAZZITE";
        fsType = "vfat";
        neededForBoot = false;
        options = [ "fmask=0022" "dmask=0022" "nofail" "ro" ];
      };

    "/boot/efi/WINNT" =
      {
        device = "/dev/disk/by-label/ESP_WINNT";
        fsType = "vfat";
        neededForBoot = false;
        options = [ "fmask=0022" "dmask=0022" "nofail" "ro" ];
      };

    "/boot/efi/NIXOS" =
      {
        device = "/dev/disk/by-label/ESP_NIXOS";
        fsType = "vfat";
        neededForBoot = true;
        options = [ "fmask=0022" "dmask=0022" ];
      };

    "/boot/efi/PRIMARY" =
      {
        device = "/dev/disk/by-label/ESP_PRIMARY";
        fsType = "vfat";
        neededForBoot = false;
        options = [ "fmask=0022" "dmask=0022" ];
      };

  };
}
