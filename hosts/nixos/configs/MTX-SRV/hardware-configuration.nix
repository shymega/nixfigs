{ modulesPath, lib, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    loader.grub = {
      enable = true;
      efiSupport = lib.mkForce false;
      devices = [ "/dev/sdas" ];
    };
    initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
    initrd.kernelModules = [ "nvme" ];
  };
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
}
