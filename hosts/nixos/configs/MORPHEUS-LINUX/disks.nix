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
      device = "zroot/crypt/root/nixos/linux/local/root";
      fsType = "zfs";
    };

    "/home/dzrodriguez/Games" = {
      depends = [ "/data/Games" ];
      device = "/data/Games";
      fsType = "none";
      neededForBoot = true;
      options = [ "bind" "uid=1000" "gid=100" ];
    };

    "/home/dzrodriguez/dev" = {
      depends = [ "/data/Development" ];
      device = "/data/Development";
      fsType = "none";
      neededForBoot = true;
      options = [ "bind" "uid=1000" "gid=100" ];
    };

    "/home" = {
      device = "zdata/crypt/shared/homes/nixos";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/etc/nixos" = {
      device = "zroot/crypt/root/nixos/linux/safe/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "zroot/crypt/root/nixos/linux/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/guix" = {
      device = "zroot/crypt/root/nixos/linux/local/guix-store";
      fsType = "zfs";
      neededForBoot = false;
    };

    "/persist" = {
      device = "zroot/crypt/root/nixos/linux/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var" = {
      device = "zroot/crypt/root/nixos/linux/safe/var-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/.local/share/atuin" = {
      device = "/dev/zvol/zroot/crypt/shared/homes/atuin/nixos";
      fsType = "ext4";
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

    "/etc/ssh" = {
      depends = [ "/persist" ];
      device = "/persist/etc/ssh";
      fsType = "none";
      neededForBoot = true;
      options = [ "bind" ];
    };
  };
}
