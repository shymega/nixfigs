# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, outputs, config, pkgs, lib, ... }:
{
  imports = [
    inputs.hardware.nixosModules.raspberry-pi-4
    ./hardware-configuration.nix
  ];

  time.timeZone = "Europe/London";

  networking = {
    hostName = "GRDN-BED-UNIT";
  };

  environment.systemPackages = with pkgs; [
    tmux
    vim
    libraspberrypi
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

  system.stateVersion = "23.11";

  networking.hostId = "3b66435d";

  services = {
    zfs = {
      trim = {
        enable = true;
        interval = "Sat *-*-* 04:00:00";
      };
      autoScrub = {
        enable = true;
        interval = "Sat *-*-* 05:00:00";
      };
    };
  };
}
