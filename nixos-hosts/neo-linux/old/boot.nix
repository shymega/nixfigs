{ config, pkgs, lib, ... }:

{
  environment.etc."crypttab".text = ''
    homecrypt /dev/disk/by-label/HOMECRYPT /root/.homecrypt_key.bin
  '';

  boot = {
    cleanTmpDir = true;

    supportedFilesystems = [ "ntfs" "xfs" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [ "quiet" ];

    initrd.luks.devices = {
      os = {
        device = "/dev/disk/by-label/NIXOS";
        preLVM = true;
        allowDiscards = true;
      };
    };

    plymouth = {
      enable = true;
      themePackages = with pkgs; [ breeze-plymouth ];
      theme = "breeze";
    };

    loader = {
      systemd-boot = { enable = true; };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };
  };
}
