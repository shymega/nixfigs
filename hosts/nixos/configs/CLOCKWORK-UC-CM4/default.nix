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
  networking = {
    hostName = "CLOCKWORK-DT-CM4";
  };
  system.stateVersion = "24.05";

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
    imageName = "CLOCKWORK-UC-CM4.img";
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

}
