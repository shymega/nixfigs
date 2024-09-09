{ disks ? [ "/dev/nvme0n1" ], ... }:
{
  disko.devices = {
    disk = {
      vda = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "ztank";
              };
            };
          };
        };
      };
    };
    zpool = {
      ztank = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "true";
          "com.sun:auto-snapshot:monthly" = "true";
          "com.sun:auto-snapshot:weekly" = "true";
          "com.sun:auto-snapshot:daily" = "true";
          "com.sun:auto-snapshot:hourly" = "true";
          "com.sun:auto-snapshot:frequent" = "true";
        };
        mountpoint = "/";

        datasets = {
          "shared/homes/nixos" = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          "shared/games" = {
            type = "zfs_fs";
            mountpoint = "/home/dzrodriguez/Games";
          };
          "shared/etc_nixos" = {
            type = "zfs_fs";
            mountpoint = "/etc/nixos";
          };
        };
      };
    };
  };
}
