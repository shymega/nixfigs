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
      device = "ztank/crypt/nixos/jovian/local/root";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/data/Games" = {
      device = "zdata/crypt/shared/games";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/Games" = {
      depends = ["/data/Games"];
      device = "/data/Games";
      fsType = "none";
      neededForBoot = false;
      options = [
        "bind"
        "nofail"
        "x-systemd.automount"
      ];
    };

    "/home" = {
      device = "zdata/crypt/shared/homes/nixos/jovian";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/etc/nixos" = {
      device = "zdata/crypt/shared/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/persist" = {
      device = "ztank/crypt/nixos/jovian/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "ztank/crypt/nixos/jovian/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/.local/share/atuin" = {
      device = "/dev/zvol/zdata/crypt/shared/homes/atuin/nixos/jovian"; # Replace with by-label.
      fsType = "ext4";
      neededForBoot = false;
      options = ["x-systemd.automount"];
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/EFI_DPRIM"; # DISK PRIMARY. Replace with `by-label`.
      fsType = "vfat";
      neededForBoot = true;
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
}
