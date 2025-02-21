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
      device = "ztank";
      fsType = "zfs";
    };

    "/home/dzrodriguez/Games" = {
      device = "ztank/shared/games";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home" = {
      device = "ztank/shared/homes/nixos";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/etc/nixos" = {
      device = "ztank/shared/etc_nixos";
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
