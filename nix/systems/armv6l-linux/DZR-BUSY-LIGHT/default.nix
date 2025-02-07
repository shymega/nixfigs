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
    ./sd-image-pi0v1.nix
  ];
  nixpkgs = {
    system = "armv6l-linux";
    crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

    # https://github.com/NixOS/nixpkgs/issues/154163#issuecomment-1350599022
    overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});
      })
    ];
  };
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
  i18n.supportedLocales = [(config.i18n.defaultLocale + "/UTF-8")];

  networking = {
    hostName = "DZR-BUSY-LIGHT";
    firewall.enable = lib.mkDefault false;
  };

  programs.zsh.enable = true;

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
      shell = pkgs.zsh;
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

  environment.systemPackages = with pkgs; [
    tmux
    vim
    raspberrypi-eeprom
  ];

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
