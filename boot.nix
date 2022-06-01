# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  boot = {
    cleanTmpDir = true;

    kernel.sysctl = { "vm.dirty_ratio" = 6; };
    extraModprobeConfig = ''
	options hid_apple fnmode=0
    '';

    kernelPackages = pkgs.linuxPackages_xanmod;

    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/03a88cc8-107d-4459-9463-c75416952782";
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
      grub = {
        enable = true;
        version = 2;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
        fsIdentifier = "uuid";
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
  };
}
