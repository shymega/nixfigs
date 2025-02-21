{ lib, config, ... }: {
  users.users."root".password = null;
  users.users."root".initialPassword = null;
  users.users."root".hashedPasswordFile = null;
  users.users."root".hashedPassword = null;
  users.users."root".openssh.authorizedKeys.keys = config.users.users."nixos".openssh.authorizedKeys.keys;
  users.users."nixos".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+E0hk4exiTZiO/UjGW8q1gu129RWcClCd60HrVUZ1c"
  ];
  users.users."nixos".password = null;
  users.users."nixos".initialPassword = null;
  users.users."nixos".hashedPasswordFile = null;
  users.users."nixos".hashedPassword = null;

  boot = {
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" "zfs" ];
  };
}
