{ pkgs, lib, user, ... }:

{
  imports = [ ./hardware-configuration.nix ./wayland.nix ./x11.nix ];

  environment.etc."crypttab".text = ''
    homecrypt /dev/disk/by-label/HOMECRYPT /persist/etc/.homecrypt.bin
  '';
  networking.hostName = "NEO-LINUX";
  time.timeZone = "Europe/London";

  boot = {
    cleanTmpDir = true;

    supportedFilesystems = [ "ntfs" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [ "quiet" ];

    initrd.luks.devices = {
      nixos = {
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
