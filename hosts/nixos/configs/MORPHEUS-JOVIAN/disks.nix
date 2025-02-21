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
      device = "zroot/crypt/nixos/jovian/local/root";
      fsType = "zfs";
      neededForBoot = true;
    };

#    "/data/Games" = {
#      device = "zdata/crypt/shared/games";
#      fsType = "zfs";
#      neededForBoot = true;
#    };

    "/data/Development" = {
      device = "zdata/crypt/shared/dev";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/data/AI" = {
      device = "zdata/crypt/shared/ai";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/data/VMs" = {
      device = "zdata/crypt/shared/virtual";
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
      device = "zroot/crypt/nixos/linux/safe/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "zroot/crypt/nixos/jovian/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      neededForBoot = false;
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
