# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  boot.zfs.requestEncryptionCredentials = true;

  fileSystems = {
  "/" =
    { device = "zosroot/crypt/nixos/local/root";
      fsType = "zfs";
    };

  "/data/Games" =
    { device = "zdata/shared/games";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/data/AI" =
    { device = "zdata/shared/ai";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/data/VMs" =
    { device = "zdata/shared/virtual";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/home" =
    { device = "zdata/shared/home-nixos";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/etc/nixos" =
    { device = "zosroot/crypt/nixos/safe/nixos-config";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/nix" =
    { device = "zosroot/crypt/nixos/local/nixos-store";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/persist" =
    { device = "zosroot/crypt/nixos/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/var" =
    { device = "zosroot/crypt/nixos/safe/var-store";
      fsType = "zfs";
      neededForBoot = true;
    };

  "/boot/efi/BAZZITE" =
    { device = "/dev/disk/by-uuid/DF1C-99B2";
      fsType = "vfat";
      neededForBoot = true;
      options = [ "fmask=0022" "dmask=0022" "nofail" "ro" ];
    };

  "/boot/efi/WINNT" =
    { device = "/dev/disk/by-uuid/BE1F-022B";
      fsType = "vfat";
      neededForBoot = false;
      options = [ "fmask=0022" "dmask=0022" "nofail" "o" ];
    };

  "/boot/efi/NIXOS" =
    { device = "/dev/disk/by-uuid/BB8E-C98E";
      fsType = "vfat";
      neededForBoot = true;
      options = [ "fmask=0022" "dmask=0022" ];
    };

  "/boot/efi/PRIMARY" =
    { device = "/dev/disk/by-uuid/BBFD-77B8";
      fsType = "vfat";
      neededForBoot = false;
      options = [ "fmask=0022" "dmask=0022" "nofail" ];
    };
  };
}
