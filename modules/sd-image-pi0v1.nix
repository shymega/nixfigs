{ inputs, pkgs, lib, ... }:

{
  nixpkgs.crossSystem = lib.systems.elaborate lib.systems.examples.raspberryPi;

  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/base.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  networking.wireless.enable = true;

  boot = {
    loader.raspberryPi.firmwareConfig = ''
      dtparam=i2c=on
    '';
    kernelModules = [
      "i2c-dev"
    ];
  };
  hardware.i2c.enable = true;

  users = {
    extraGroups = {
      gpio = { };
    };
    extraUsers.pi = {
      isNormalUser = true;
      initialPassword = "raspberry";
      extraGroups = [ "wheel" "networkmanager" "dialout" "gpio" "i2c" ];
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
