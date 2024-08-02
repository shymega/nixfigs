# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  nixpkgs.hostPlatform.system = "armv6l-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux";
  # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  networking = {
    hostName = "DZR-OFFICE-BUSY-LIGHT-UNIT";
  };

  environment.systemPackages = with pkgs; [
    tmux
    vim
    libraspberrypi
    raspberrypi-eeprom
    nixpkgs-fmt
  ];

  system.stateVersion = "24.05";

  sdImage = {
    compressImage = false;
    imageName = "DZR-OFFICE-BUSY-LIGHT-UNIT.img";

    populateRootCommands = "";
    populateFirmwareCommands = with config.system.build; ''
      ${installBootLoader} ${toplevel} -d ./firmware
    '';
    firmwareSize = 64;
  };

  hardware = {
    # needed for wlan0 to work (https://github.com/NixOS/nixpkgs/issues/115652)
    enableRedistributableFirmware = pkgs.lib.mkForce false;
    firmware = with pkgs; [
      raspberrypiWirelessFirmware
    ];
  };

  networking = {
    interfaces."wlan0".useDHCP = true;
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      networks = {
        "RNET" = {
          psk = lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.home_network_iot_p.path);
        };
      };
    };
  };
}
