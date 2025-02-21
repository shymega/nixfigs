# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{
  boot.zfs = {
    requestEncryptionCredentials = true;
    forceImportAll = true;
  };

  fileSystems = {
    "/" = {
      device = "zdata/crypt/root/nixos/jovian/local/root";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home" = {
      device = "zdata/crypt/shared/homes/jovian";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/.local/share/atuin" = {
      device = "/dev/zvol/zdata/crypt/shared/homes/atuin/jovian";
      fsType = "ext4";
    };

    "/etc/nixos" = {
      device = "zdata/crypt/root/nixos/jovian/safe/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "zdata/crypt/root/nixos/jovian/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      neededForBoot = true;
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
