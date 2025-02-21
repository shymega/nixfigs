# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  nixpkgs = {
    system = "armv6l-linux";
    crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

    # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
    overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };
  networking = {
    hostName = "DZR-PETS-CAM-UNIT";
  };

  # no GUI environment
  environment.noXlibs = lib.mkDefault true;

  # don't build documentation
  documentation.info.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;

  # don't include a 'command not found' helper
  programs.command-not-found.enable = lib.mkDefault false;

  # disable firewall (needs iptables)
  networking.firewall.enable = lib.mkDefault false;

  # disable polkit
  security.polkit.enable = lib.mkDefault false;

  # disable audit
  security.audit.enable = lib.mkDefault false;

  # disable udisks
  services.udisks2.enable = lib.mkDefault false;

  # disable containers
  boot.enableContainers = lib.mkDefault false;

  # build less locales
  # This isn't perfect, but let's expect the user specifies an UTF-8 defaultLocale
  i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];

  environment.systemPackages = with pkgs; [
    tmux
    vim
    raspberrypi-eeprom
    nixpkgs-fmt
  ];

  system.stateVersion = "24.05";

  sdImage = {
    compressImage = false;
    imageName = "DZR-PETS-CAM-UNIT.img";

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
