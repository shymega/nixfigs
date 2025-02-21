{ modulesPath, lib, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    loader.grub = {
      efiSupport = lib.mkForce false;
    };
    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
    initrd.kernelModules = [ "nvme" ];
  };
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
}
