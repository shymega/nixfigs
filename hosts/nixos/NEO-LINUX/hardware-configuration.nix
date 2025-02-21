{ config, lib, ... }:
{
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "hid_apple"
    ];
    initrd.kernelModules = [ "dm-snapshot" "amdgpu" ];
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    resumeDevice = "/dev/disk/by-label/SWAP";
  };

  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  fileSystems = {
    "/" =
      {
        device = "tank/local/root";
        fsType = "zfs";
      };

    "/nix" =
      {
        device = "tank/local/nix";
        neededForBoot = true; # required
        fsType = "zfs";
      };

    "/persist" =
      {
        device = "tank/safe/persist";
        neededForBoot = true; # required
        fsType = "zfs";
      };

    "/var/log" =
      {
        device = "tank/safe/log";
        neededForBoot = true; # required
        fsType = "zfs";
      };

    "/etc/nixos" =
      {
        device = "tank/safe/nixos-config";
        neededForBoot = true; # required
        fsType = "zfs";
      };

    "/boot" = {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
      neededForBoot = true; # required
    };


    "/home" = {
      device = "/dev/disk/by-label/HOME";
      fsType = "xfs";
    };

    "/data" = {
      device = "/dev/disk/by-label/SHARED0";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "ssd" ];
    };
  };
  swapDevices = [{ device = "/dev/disk/by-label/SWAP"; }];


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
