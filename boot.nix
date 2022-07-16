# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  boot = {
    cleanTmpDir = true;

    kernel.sysctl = { "vm.dirty_ratio" = 6; };
    extraModprobeConfig = ''
      options snd-intel-dspcfg dsp_driver=1
      options hid_apple fnmode=0
    '';

    #    kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_xanmod_latest;

    kernelParams = [
      "fbcon=rotate:1"
      "video=DSI-1:panel_orientation=right_side_up"
      "video=efifb"
      "mem_sleep_default=s2idle"
    ];

    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/8aec666e-0655-4e09-a25d-acb431624828";
        preLVM = true;
        allowDiscards = true;
      };
    };

    plymouth = {
      enable = false;
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
        gfxmodeEfi = "768x1024";
      };
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 3;
    };
  };
}
