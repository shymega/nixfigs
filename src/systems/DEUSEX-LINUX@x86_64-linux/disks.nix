# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  boot.zfs = {
    requestEncryptionCredentials = true;
    forceImportAll = true;
  };

  fileSystems = {
    "/" = {
      device = "ztank/crypt/nixos/linux/local/root";
      fsType = "zfs";
    };

    "/data/VMs" = {
      device = "zdata/crypt/shared/virtual";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/data/AI" = {
      device = "zdata/crypt/shared/ai";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/data/Development" = {
      device = "zdata/crypt/shared/dev";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/data/Games" = {
      device = "zdata/crypt/shared/games";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/Games" = {
      depends = [ "/data/Games" ];
      device = "/data/Games";
      fsType = "none";
      neededForBoot = false;
      options = [
        "bind"
        "nofail"
        "x-systemd.automount"
      ];
    };

    "/var/lib/ollama" = {
      depends = [ "/data/AI" ];
      device = "/data/AI/LLMs/Ollama/Models";
      fsType = "none";
      neededForBoot = false;
      options = [
        "bind"
        "nofail"
        "x-systemd.automount"
      ];
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
      device = "zdata/crypt/shared/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/nix" = {
      device = "ztank/crypt/nixos/linux/local/nix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/gnu" = {
      device = "ztank/crypt/nixos/linux/local/guix-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/persist" = {
      device = "ztank/crypt/nixos/linux/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var" = {
      device = "ztank/crypt/nixos/linux/safe/var-store";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home/dzrodriguez/.local/share/atuin" = {
      device = "/dev/zvol/zdata/crypt/shared/homes/atuin/nixos/linux"; # Replace with by-label.
      fsType = "ext4";
      neededForBoot = false;
      options = [ "x-systemd.automount" ];
    };

    "/boot/efi" = {
      device = "/dev/disk/by-label/EFI_DPRIM"; # DISK PRIMARY. Repalce with by-label.
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
