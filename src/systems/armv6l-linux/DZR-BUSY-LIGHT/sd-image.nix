{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  nixpkgs.crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

  imports = [
    "${inputs.nixpkgs}//nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
    ./minification.nix
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    libgpiod
    gpio-utils
    i2c-tools
    nano
    tmux
    git
  ];

  networking.wireless.enable = true;

  boot = {
    kernelModules = [
      "i2c-dev"
    ];
  };
  hardware.i2c.enable = true;

  users = {
    extraGroups = {
      gpio = {};
    };
  };
  services.getty.autologinUser = "app";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  services.udev = {
    extraRules = ''
      KERNEL=="gpiochip0*", GROUP="gpio", MODE="0660"
    '';
  };
}
