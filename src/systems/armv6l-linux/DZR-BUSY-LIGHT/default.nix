# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the system system.
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./sd-image.nix
  ];
  nixpkgs = {
    hostPlatform.system = "${system}";
    buildPlatform.system = "${pkgs.system}";
    config.allowUnsupportedSystem = true;
  };

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
      password = "changeme!";
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
    firmware = with pkgs; [raspberrypiWirelessFirmware];
  };

  networking = {
    interfaces."wlan0".useDHCP = true;
    networkmanager.enable = lib.mkForce false;
    wireless = {
      enable = true;
    };
  };
  system.stateVersion = "24.11";
}
