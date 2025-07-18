# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  pkgs,
  inputs,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./sd-image.nix
  ];
  nixpkgs = {
    hostPlatform.system = "armv6l-linux";
    buildPlatform.system = "${pkgs.system}";
  };

  disabledModules = [
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
  ];

  networking = {
    hostName = "DZR-BUSY-LIGHT";
    firewall.enable = lib.mkForce false;
  };

  users = {
    mutableUsers = false;
    users."root".password = "!"; # Lock account.
    users."app" = {
      isNormalUser = true;
      password = "!";
      linger = true;
    };
    users."dzrodriguez" = {
      isNormalUser = true;
      description = "Dom RODRIGUEZ";
      password = lib.mkForce "changeme";
      linger = true;
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
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

  sdImage = {
    compressImage = true;
    imageName = "DZR-BUSY-LIGHT.img";

    populateRootCommands = "";
    populateFirmwareCommands = with config.system.build; ''
      ${installBootLoader} ${toplevel} -d ./firmware
    '';
    firmwareSize = 64;
  };

  hardware = {
    # needed for wlan0 to work (https://github.com/NixOS/nixpkgs/issues/115652)
    enableRedistributableFirmware = pkgs.lib.mkForce false;
    firmware = with pkgs; [ raspberrypiWirelessFirmware ];
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
