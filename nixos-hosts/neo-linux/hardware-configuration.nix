{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "hid_apple"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Filesystems (root on tmpfs)
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    neededForBoot = true; # required
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/NIXOS_BTRFS_ROOT";
    fsType = "btrfs";
    options =
      [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=nix-store" ];
    neededForBoot = true; # required
  };

  fileSystems."/etc/nixos" = {
    device = "/dev/disk/by-label/NIXOS_BTRFS_ROOT";
    fsType = "btrfs";
    options = [
      "defaults"
      "compress-force=zstd"
      "noatime"
      "ssd"
      "subvol=nixos-config"
    ];
    neededForBoot = true; # required

  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/NIXOS_BTRFS_ROOT";
    fsType = "btrfs";
    options = [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=log" ];
    neededForBoot = true; # required

  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/NIXOS_BTRFS_ROOT";
    fsType = "btrfs";
    options =
      [ "defaults" "compress-force=zstd" "noatime" "ssd" "subvol=persist" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  swapDevices = [{ device = "/dev/disk/by-label/SWAP"; }];

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  fileSystems."/home" = {
    device = "/dev/disk/by-label/HOME";
    fsType = "xfs";
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-label/WINLINSHARE";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "gid=100" "user" "exec" "umask=000" "nofail" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
