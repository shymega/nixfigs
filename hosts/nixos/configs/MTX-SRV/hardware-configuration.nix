{ modulesPath, lib, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      systemd-boot.enable = lib.mkForce false;
      grub = {
        enable = true;
        efiSupport = true;
        device = lib.mkForce "nodev";
      };
    };
    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
    initrd.kernelModules = [ "nvme" ];
  };
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
  fileSystems."/boot/efi" = { device = "/dev/sda2"; fsType = "vfat"; };
}
