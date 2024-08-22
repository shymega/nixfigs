# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/base.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  networking.wireless.enable = true;

  boot = {
    loader.raspberryPi.firmwareConfig = ''
      dtparam=i2c=on
    '';
    kernelModules = [ "i2c-dev" ];
  };
  hardware.i2c.enable = true;

  users = {
    extraGroups = {
      gpio = { };
    };
    extraUsers.pi = {
      isNormalUser = true;
      initialPassword = "raspberry";
      extraGroups = [
        "wheel"
        "networkmanager"
        "dialout"
        "gpio"
        "i2c"
      ];
    };
  };
  services = {
    getty.autologinUser = "pi";

    openssh = {
      enable = true;
    };

    udev = {
      extraRules = ''
        KERNEL=="gpiochip0*", GROUP="gpio", MODE="0660"
      '';
    };
  };
}
