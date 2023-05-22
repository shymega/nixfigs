{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "hid_apple"
  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
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
    neededForBoot = true; # required
  };

  swapDevices = [{ device = "/dev/disk/by-label/SWAP"; }];

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  fileSystems."/home" = {
    device = "/dev/disk/by-label/HOME";
    fsType = "xfs";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
