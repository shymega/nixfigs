# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
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
        inputs.nix-ld.nixosModules.nix-ld
        inputs.nix-index-database.nixosModules.nix-index
        {
          environment.systemPackages = [
            inputs.agenix.packages.${system}.default
          ];
        }
        ../secrets
        (../hosts/nixos + "/${hostname}")
      ] ++ baseModules ++ hardwareModules ++ homeModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs; };
    };

  mkHomeManagerConfig =
    { usePkgs ? true
    , extraModules ? [
      ]
    , specialArgs ? [{ inherit self inputs; }]
    }:
    inputs.home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = usePkgs;
        useUserPackages = usePkgs;
        sharedModules = [
          inputs.agenix.homeManagerModules.default
        ] ++ extraModules;
        extraSpecialArgs = specialArgs;
      };
    };

in
{
  ### Personal Devices ####

  ### Desktops ###

  ## Desktop (Beelink SER6 Pro) ##

  NEO-LINUX = mkNixosConfig {
    hostname = "NEO-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      ../hosts/nixos/NEO-LINUX/hardware-configuration.nix
    ];
    extraModules = [
      ../hosts/nixos/configuration.nix
    ];
  };

  ## End Desktop (Beelink SER6 Pro) ##

  ## Raspberry Pi - desk ##
  ## End Raspberry Pi - desk ##

  ### End Desktops ###

  ### Portable Machines ###

  ## UMPC (GPD Pocket 3 (i7)) ##
  TRINITY-LINUX = mkNixosConfig {
    hostname = "TRINITY-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.common-cpu-intel
      inputs.hardware.nixosModules.common-gpu-intel
      inputs.hardware.nixosModules.gpd-pocket-3
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      ../hosts/nixos/TRINITY-LINUX/hardware-configuration.nix
    ];
    extraModules = [
      ../hosts/nixos/configuration.nix
    ];
  };

  ## End UMPC (GPD P3) ##

  # Laptop (ThinkPad X270) ##

  TWINS-LINUX = mkNixosConfig {
    hostname = "TWINS-LINUX";
    system = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.lenovo-thinkpad-x270
      inputs.hardware.nixosModules.common-cpu-intel
      inputs.hardware.nixosModules.common-gpu-intel
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
      ../hosts/nixos/TWINS-LINUX/hardware-configuration.nix
    ];
    extraModules = [
      ../hosts/nixos/configuration.nix
    ];
  };

  # End Laptop (ThinkPad X270) ##

  ### End Portable Machines ###

  ### Handhelds ###

  ## Gaming Handheld (GPD Win Max 2 (2023)) ##
  ## TO BE ADDED. ##
  ## End Gaming Handheld (GPD Win Max 2 (2023) ##

  ## Gaming Handheld (Steam Deck (OLED/1TB)) ##
  ## TO BE ADDED. ##
  ## End Gaming Handheld (Steam Deck (OLED/1TB)) ##

  ### End Handhelds ###

  ### Experimental Device Ports ###

  ## RISC-V Experimental Tablet (Pine64 PineTab2-V) ##
  ## TO BE ADDED. ##
  ## End RISC-v Experimental Tablet (Pine64 PineTab2-V) ##

  ## ARM64 Experimental Tablet (Pine64 PineTab2 ARM64) ##
  ## TO BE ADDED. ##
  ## End ARM64 Experimental Tablet (Pine64 PineTab2 ARM) ##

  ## ClockworkPi uConsole (CM4) ##
  ## TO BE ADDED. ##
  ## End ClockworkPi uConsole (CM4) ##

  ## ClockworkPi DevTerm (CM4) ##
  ## TO BE ADDED. ##
  ## End ClockworkPi DevTerm (CM4) ##

  ### Experimental Device Ports ###

  ### Servers ###

  ### End Servers ###

  ### Cloud Machines (VMs/Containers) ###

  ### End Cloud Machines (VMs/Containers) ###

  ### Local Machines (VMs/Containers) ###

  ### End Local Machines (VMs/Containers) ###

  ## Home Automation Nodes ##

  ## End Home Automation Nodes ##

  ### End Personal Machines ###

  ### Work Machines ###

  ### End Work Machines ###
}
