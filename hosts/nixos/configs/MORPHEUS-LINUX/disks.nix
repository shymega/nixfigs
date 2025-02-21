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
      device = "zosroot/crypt/nixos/local/root";
      fsType = "zfs";
    };

    "/data/AI" = {
      device = "zdata/shared/ai";
      fsType = "zfs";
      neededForBoot = false;
    };

    "/data/VMs" = {
      device = "zdata/shared/virtual";
      fsType = "zfs";
      neededForBoot = false;
    };

    "/home" = {
      device = "zdata/shared/home-nixos";
      fsType = "zfs";
      neededForBoot = false;
    };

    "/etc/nixos" = {
      device = "zosroot/crypt/nixos/safe/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "zosroot/crypt/nixos/local/nixos-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/persist" = {
      device = "zosroot/crypt/nixos/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var" = {
      device = "zosroot/crypt/nixos/safe/var-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/.local/share/atuin" = {
      device = "/dev/disk/by-label/ATUIN_NIXOS";
      fsType = "ext4";
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

    "/etc/ssh" = {
      depends = [ "/persist" ];
      device = "/persist/etc/ssh";
      fsType = "none";
      neededForBoot = true;
      options = [ "bind" ];
    };
  };
}
