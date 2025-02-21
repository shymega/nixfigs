{ lib, config, ... }: {
  users.users."root".password = null;
  users.users."root".initialPassword = null;
  users.users."root".hashedPasswordFile = null;
  users.users."root".hashedPassword = null;
  users.users."root".openssh.authorizedKeys.keys = config.users.users."nixos".openssh.authorizedKeys.keys;
  users.users."nixos".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrrpI4JTUIr0TC39r1K3nxyieCLi1aqH413+7ulSy5t"
  ];
  users.users."nixos".password = null;
  users.users."nixos".initialPassword = null;
  users.users."nixos".hashedPasswordFile = null;
  users.users."nixos".hashedPassword = null;

  systemd = {
    network = {
      enable = true;
      networks = {
        "10-lan" = {
          matchConfig.Name = [ "eno1" ];
          networkConfig = {
            Bridge = "vmbr0";
          };
        };
        "10-lan-bridge" = {
          matchConfig.Name = "vmbr0";
          address = [ "78.129.218.104/24" ];
          routes = [{ routeConfig.Gateway = "78.129.218.1"; }];
          linkConfig.RequiredForOnline = "routable";
        };
      };

      netdevs."vmbr0" = {
        netdevConfig = {
          Name = "vmbr0";
          Kind = "bridge";
        };
      };
    };
  };

  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs" ];
  };
}
