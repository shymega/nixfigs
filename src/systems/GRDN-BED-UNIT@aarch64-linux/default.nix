# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = with inputs; [
    ./hardware-configuration.nix
    hardware.nixosModules.raspberry-pi-4
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking = {
    hostName = "GRDN-BED-UNIT";
  };

  boot.supportedFilesystems.zfs = lib.mkForce false;

  users = {
    mutableUsers = false;
    users."root".password = "!"; # Lock account.
    users."dzrodriguez" = {
      isNormalUser = true;
      description = "Dom RODRIGUEZ";
      password = "!";
      linger = true;
      extraGroups = [
        "i2c"
        "disk"
        "input"
        "kvm"
        "plugdev"
        "systemd-journal"
        "wheel"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    tmux
    vim
    raspberrypi-eeprom
    nixpkgs-fmt
  ];

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    raspberry-pi."4".fkms-3d.enable = true;
    deviceTree = {
      enable = true;
      filter = lib.mkForce "bcm2711-rpi-4*.dtb";
    };
  };

  sdImage = {
    compressImage = false;
    imageName = "GRDN-BED-UNIT.img";
  };

  networking = {
    interfaces."wlan0".useDHCP = true;
    networkmanager.enable = lib.mkForce false;
    wireless = {
      enable = true;
    };
  };

  system.stateVersion = "25.05";
}
