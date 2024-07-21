# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  mkNixosConfig =
    { system ? "x86_64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/nixos
        ../common/core
      ]
    , hardwareModules ? [ ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = import nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
        config = {
          allowUnfree = true;
          allowBroken = false;
          allowInsecure = false;
          allowUnsupportedSystem = false;
        };
      };

      modules = [
        inputs.agenix.nixosModules.default
        ../secrets/system
        (../hosts/nixos + "/${hostname}")
      ] ++ baseModules ++ hardwareModules ++ homeModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs hostname system; };
    };
in
{
  ### Personal Devices ####

  ### Desktops ###

  ## Desktop (Beelink SER6 Pro) ##

  NEO-LINUX = mkNixosConfig rec {
    hostname = "NEO-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }
      ../hosts/nixos/configuration.nix
    ];
  };

  ## End Desktop (Beelink SER6 Pro) ##

  ## Raspberry Pi - desk ##

  SMITH-LINUX = mkNixosConfig rec {
    hostname = "SMITH-LINUX";
    system = "aarch64-linux";
    baseModules = [ ];
    hardwareModules = [
      inputs.hardware.nixosModules.raspberry-pi-4
    ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }

      ./24.05-compat.nix
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
  };

  ## End Raspberry Pi - desk ##

  # Laptop (ThinkPad X270) ##

  TWINS-LINUX = mkNixosConfig rec {
    hostname = "TWINS-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.lenovo-thinkpad-x270
    ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }

      ../hosts/nixos/configuration.nix
    ];
  };

  # End Laptop (ThinkPad X270) ##

  ### Handhelds ###

  ## Gaming Handheld (GPD Win Max 2 (2024)) ##

  MORPHEUS-LINUX = mkNixosConfig rec {
    hostname = "MORPHEUS-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.gpd-win-max-2-2023
    ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }

      ../hosts/nixos/configuration.nix
    ];
  };

  ## End Gaming Handheld (GPD Win Max 2 (2024) ##

  ## Gaming Handheld (Steam Deck (OLED/2TB)) ##
  ## TO BE ADDED. ##
  ## End Gaming Handheld (Steam Deck (OLED/2TB)) ##
  ### End Handhelds ###

  ### Pi Units ###

  GRDN-BED-UNIT = mkNixosConfig rec {
    hostname = "GRDN-BED-UNIT";
    system = "aarch64-linux";
    baseModules = [ ];
    hardwareModules = [
      inputs.hardware.nixosModules.raspberry-pi-4
    ];
    extraModules = [
      ./24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }

      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
  };

  DZR-OFFICE-BUSY-LIGHT-UNIT = mkNixosConfig rec {
    hostname = "DZR-OFFICE-BUSY-LIGHT-UNIT";
    system = "armv6l-linux";
    baseModules = [ ];
    extraModules = [
      ./24.05-compat.nix
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
    ];
  };

  DZR-PETS-CAM-UNIT = mkNixosConfig rec {
    hostname = "DZR-PETS-CAM-UNIT";
    system = "armv6l-linux";
    baseModules = [ ];
    extraModules = [
      ./24.05-compat.nix
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
    ];
  };

  ### End Pi Unitss ###

  ### Experimental Device Ports ###

  ## ClockworkPi uConsole (CM4) ##
  # Received, Debian installed. Work ongoing to upstream DTB and driver patches. #
  #  CLOCKWORK-UC-CM4 = mkNixosConfig rec {
  #    hostname = "CLOCKWORK-UC-CM4";
  #    system = "aarch64-linux";
  #    baseModules = [ ];
  #    hardwareModules = [
  #      inputs.hardware.nixosModules.raspberry-pi-4
  #    ];
  #    extraModules = [
  #      ./24.05-compat.nix
  #      {
  #        environment.systemPackages = [
  #          inputs.agenix.packages.${system}.default
  #          inputs.nix-alien.packages.${system}.nix-alien
  #        ];
  #      }
  #      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  #    ];
  #  };

  ## End ClockworkPi uConsole (CM4) ##

  ## ClockworkPi DevTerm (CM4) ##
  #  CLOCKWORK-DT-CM4 = mkNixosConfig rec {
  #    hostname = "CLOCKWORK-DT-CM4";
  #    system = "aarch64-linux";
  #    baseModules = [ ];
  #    hardwareModules = [
  #      inputs.hardware.nixosModules.raspberry-pi-4
  #    ];
  #    extraModules = [
  #      ./24.05-compat.nix
  #      {
  #        environment.systemPackages = [
  #          inputs.agenix.packages.${system}.default
  #          inputs.nix-alien.packages.${system}.nix-alien
  #        ];
  #      }
  #      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  #    ];
  #  };
  ## End ClockworkPi DevTerm (CM4) ##

  ### End Experimental Device Ports ###
}
