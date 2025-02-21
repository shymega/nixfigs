# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config
, pkgs
, lib
, ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  nixpkgs = {
    system = "armv6l-linux";
    crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

    # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
    overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };
  # no GUI environment
  environment.noXlibs = lib.mkDefault true;

  boot.supportedFilesystems.zfs = lib.mkForce false;

  # don't build documentation
  documentation.info.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;

  # don't include a 'command not found' helper
  programs.command-not-found.enable = lib.mkDefault false;

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

  networking = {
    hostName = "DZR-OFFICE-BUSY-LIGHT-UNIT";
    firewall.enable = lib.mkDefault false;
  };

  users = {
    mutableUsers = false;
    users."root".password = "!"; # Lock account.
    users."dzrodriguez" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Dom RODRIGUEZ";
      hashedPasswordFile = config.age.secrets.dzrodriguez.path;
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
        "adbusers"
        "dialout"
        "disk"
        "docker"
        "input"
        "kvm"
        "libvirt"
        "libvirtd"
        "lp"
        "lpadmin"
        "networkmanager"
        "plugdev"
        "qemu-libvirtd"
        "scanner"
        "systemd-journal"
        "uucp"
        "video"
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
    firmware = with pkgs; [ raspberrypiWirelessFirmware ];
  };

  networking = {
    interfaces."wlan0".useDHCP = true;
    networkmanager.enable = lib.mkForce false;
    wireless = {
      enable = true;
      environmentFile = config.age.secrets.wireless.path;
      networks = {
        "RNET" = {
          psk = "@PSK_RNET@";
        };
      };
    };
  };
  system.stateVersion = "24.05";

}
