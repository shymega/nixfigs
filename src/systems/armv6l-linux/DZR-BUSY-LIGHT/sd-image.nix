{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  nixpkgs.crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

  imports = [
    "${inputs.nixpkgs}//nixos/modules/profiles/base.nix"
    "${inputs.nixpkgs}//nixos/modules/installer/sd-card/sd-image.nix"
    ./minification.nix
  ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
    libgpiod
    gpio-utils
    i2c-tools
    screen
    vim
    git
    bottom
    (python39.withPackages (ps:
      with ps; [
        adafruit-pureio
        pyserial
      ]))
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
  services.getty.autologinUser = "pi";

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
