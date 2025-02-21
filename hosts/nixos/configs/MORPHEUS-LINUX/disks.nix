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
      device = "zroot/crypt/nixos/linux/local/root";
      fsType = "zfs";
    };

#    "/data/Games" = {
#      device = "zdata/crypt/shared/games";
#      fsType = "zfs";
#      neededForBoot = false;
#    };

    "/data/VMs" = {
      device = "zdata/crypt/shared/virtual";
      fsType = "zfs";
      neededForBoot = false;
    };

    "/data/AI" = {
      device = "zdata/crypt/shared/ai";
      fsType = "zfs";
      neededForBoot = false;
    };

    "/data/Development" = {
      device = "zdata/crypt/shared/dev";
      fsType = "zfs";
      neededForBoot = false;
    };

    "/home/dzrodriguez/Games" = {
      depends = [ "/data/Games" ];
      device = "/data/Games";
      fsType = "none";
      neededForBoot = false;
      options = [ "bind" ];
    };

    "/home/dzrodriguez/dev" = {
      depends = [ "/data/Development" ];
      device = "/data/Development";
      fsType = "none";
      neededForBoot = false;
      options = [ "bind" ];
    };

    "/home" = {
      device = "zdata/crypt/shared/homes/nixos";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/etc/nixos" = {
      device = "zroot/crypt/nixos/linux/safe/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "zroot/crypt/nixos/linux/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/gnu" = {
      device = "zroot/crypt/nixos/linux/local/guix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/persist" = {
      device = "zroot/crypt/nixos/linux/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var" = {
      device = "zroot/crypt/nixos/linux/safe/var-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/.local/share/atuin" = {
      device = "/dev/zvol/zdata/crypt/shared/homes/atuin/nixos";
      fsType = "ext4";
      neededForBoot = false;
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

    "/boot/efi_alt" = {
      device = "/dev/disk/by-label/ESP_ALT";
      fsType = "vfat";
      neededForBoot = true;
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/boot/efi_bsd" = {
      device = "/dev/disk/by-label/ESP_BSD";
      fsType = "vfat";
      neededForBoot = true;
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
