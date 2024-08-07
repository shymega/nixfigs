# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  networking = {
    hostName = "SMITH-LINUX";
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
  system.stateVersion = "24.05";
  sdImage.compressImage = false;
}
