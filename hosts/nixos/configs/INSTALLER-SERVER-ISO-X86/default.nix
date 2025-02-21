{ lib, config, ... }: {
  users = {
    users = {
      "root" = {
        password = null;
        initialPassword = null;
        hashedPasswordFile = null;
        hashedPassword = null;
        openssh.authorizedKeys.keys = config.users.users."nixos".openssh.authorizedKeys.keys;
      };
      "nixos" = {

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrrpI4JTUIr0TC39r1K3nxyieCLi1aqH413+7ulSy5t"
        ];
        password = null;
        initialPassword = null;
        hashedPasswordFile = null;
        hashedPassword = null;
      };
    };
  };

  networking.dhcpcd.enable = true;

  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs" ];
  };
}
