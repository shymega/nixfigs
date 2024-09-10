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
      device = "tank/jovian/local/root";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home" = {
      device = "/dev/disk/by-label/HOME";
      fsType = "xfs";
      neededForBoot = true;
    };

    "/etc/nixos" = {
      device = "tank/jovian/safe/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/persist" = {
      device = "tank/jovian/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "tank/jovian/local/nix";
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
