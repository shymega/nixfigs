# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  genPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
  lib = hostPlatform: inputs.nixpkgs.lib.extend
    (
      _final: prev: {
        my = import ../../lib {
          inherit self inputs;
          lib = prev;
          pkgs = genPkgs hostPlatform;
        };
      }
    ) // inputs.nixpkgs.lib;
  hasSuffix =
    suffix: content:
    let
      inherit (builtins) stringLength substring;
      lenContent = stringLength content;
      lenSuffix = stringLength suffix;
    in
    lenContent >= lenSuffix && substring (lenContent - lenSuffix) lenContent content == suffix;
  mkHost =
    { type ? "nixos"
    , address ? null
    , hostname ? null
    , hostPlatform ? "x86_64-linux"
    , username ? "dzrodriguez"
    , baseModules ? [
        ../common
        inputs.agenix.nixosModules.default
        inputs.auto-cpufreq.nixosModules.default
        {
          environment.systemPackages = [
            inputs.agenix.packages.${hostPlatform}.default
            inputs.nix-alien.packages.${hostPlatform}.nix-alien
          ];
        }
      ]
    , whopper ? true
    , hardwareModules ? [ ]
    , extraModules ? [ ]
    , pubkey ? null
    , remoteBuild ? true
    , deployable ? false
    , embedHm ? false
    ,
    }:
    if type == "nixos" then
      assert address != null;
      assert (hasSuffix "linux" hostPlatform);
      {
        inherit
          type
          hostPlatform
          address
          pubkey
          remoteBuild
          username
          hostname
          extraModules
          deployable
          baseModules
          whopper
          hardwareModules
          embedHm
          ;
      }
    else if type == "darwin" then
      assert pubkey != null && address != null;
      assert (hasSuffix "darwin" hostPlatform);
      {
        inherit
          type
          hostPlatform
          address
          pubkey
          remoteBuild
          username
          hostname
          extraModules
          deployable
          baseModules
          whopper
          hardwareModules
          ;
      }
    else if type == "home-manager" then
      assert ((hasSuffix "linux" hostPlatform) || (hasSuffix "darwin" hostPlatform) && hostname == null);
      assert pubkey == null;
      {
        inherit
          type
          hostPlatform
          username
          hostname
          deployable
          ;
      }
    else
      throw "unknown host type '${type}'";
in
{
  NEO-LINUX = mkHost rec {
    type = "nixos";
    address = "NEO-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "NEO-LINUX";
    hostPlatform = "x86_64-linux";
    hardwareModules = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-amd
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      { environment.systemPackages = [ inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl ]; }
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = true;
  };

  NEO-WSL = mkHost {
    type = "nixos";
    address = "NEO-WINDOWS.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "NEO-WSL";
    hostPlatform = "x86_64-linux";
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  MORPHEUS-LINUX = mkHost rec {
    type = "nixos";
    address = "MORPHEUS-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "MORPHEUS-LINUX";
    hostPlatform = "x86_64-linux";
    hardwareModules = [ inputs.hardware.nixosModules.gpd-win-max-2-2023 ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      { environment.systemPackages = [ inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl ]; }
    ];
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqOAfNq3lGPElJ0L6qAqQLDykRWsN9dE4sMZkD6YVKu";
    remoteBuild = true;
    deployable = true;
  };

  MORPHEUS-WSL = mkHost {
    type = "nixos";
    address = "MORPHEUS-WINDOWS.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "MORPHEUS-WINDOWS";
    hostPlatform = "x86_64-linux";
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqOAfNq3lGPElJ0L6qAqQLDykRWsN9dE4sMZkD6YVKu";
    remoteBuild = true;
    deployable = false;
  };

  TWINS-LINUX = mkHost rec {
    type = "nixos";
    address = "TWINS-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "TWINS-LINUX";
    hostPlatform = "x86_64-linux";
    hardwareModules = [ inputs.hardware.nixosModules.lenovo-thinkpad-x270 ];
    extraModules = [
      inputs.chaotic.nixosModules.default
      inputs.lanzaboote.nixosModules.lanzaboote
      { environment.systemPackages = [ inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl ]; }
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  TWINS-WSL = mkHost {
    type = "nixos";
    address = "TWINS-WINDOWS.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "TWINS-WINDOWS";
    hostPlatform = "x86_64-linux";
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  SMITH-LINUX = mkHost rec {
    type = "nixos";
    address = "SMITH-LINUX.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "SMITH-LINUX";
    hostPlatform = "aarch64-linux";
    whopper = false;
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  GRDN-BED-UNIT = mkHost rec {
    type = "nixos";
    address = "GRDN-BED-UNIT.dzr.devices.10bsk.rnet.rodriguez.org.uk";
    hostname = "GRDN-BED-UNIT";
    hostPlatform = "aarch64-linux";
    whopper = false;
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
    pubkey = "";
    remoteBuild = true;
    deployable = false;
  };

  DELTA-ZERO = mkHost {
    type = "nixos";
    address = "delta-zero.rodriguez.org.uk";
    hostname = "DELTA-ZERO";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOBP4prVx3gdi5YMW4dzy06s46aobpyY8IlFBDVgjDU";
    remoteBuild = true;
    deployable = true;
  };

  DIAL-IN-RNET = mkHost {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    hostname = "DIAL-IN-RNET";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    extraModules = [
      inputs.srvos.nixosModules.server
      inputs.srvos.nixosModules.hardware-hetzner-cloud-arm
      inputs.srvos.nixosModules.mixins-terminfo
      inputs.hardware.nixosModules.common-pc-ssd
      inputs.hardware.nixosModules.common-pc
    ];
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd2G/XmmLSK4V+tBgkS62/qE4fsY8c0dYKyjkiYtqpX";
    remoteBuild = true;
    deployable = true;
  };

  "dzrodriguez@x86_64-linux" = mkHost {
    type = "home-manager";
    username = "dzrodriguez";
    hostPlatform = "x86_64-linux";
  };

  "dzrodriguez@aarch64-linux" = mkHost {
    type = "home-manager";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
  };

  DZR-OFFICE-BUSY-LIGHT-UNIT = mkHost rec {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    baseModules = [ ../common ];
    hostPlatform = "armv6l-linux";
    remoteBuild = true;
    deployable = false;
    whopper = false;
    hostname = "DZR-OFFICE-BUSY-LIGHT-UNIT";
    extraModules = [
      ../nix/24.05-compat.nix
      (import ../nix/sd-image-pi0v1.nix {
        inherit inputs;
        lib = lib hostPlatform;
        pkgs = (lib hostPlatform).my.genPkgs hostPlatform;
      })
    ];
  };

  DZR-PETS-CAM-UNIT = mkHost rec {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    baseModules = [ ../common ];
    hostPlatform = "armv6l-linux";
    remoteBuild = true;
    deployable = false;
    whopper = false;
    hostname = "DZR-PETS-CAM-UNIT";
    extraModules = [
      ../nix/24.05-compat.nix
      (import ../nix/sd-image-pi0v1.nix {
        inherit inputs;
        lib = lib hostPlatform;
        pkgs = (lib hostPlatform).my.genPkgs hostPlatform;
      })
    ];
  };

  ### Experimental Device Ports ###
  ## ClockworkPi uConsole (CM4) ##
  # Received, Debian installed. Work ongoing to upstream DTB and driver patches. #
  CLOCKWORK-UC-CM4 = mkHost rec {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    hostname = "CLOCKWORK-UC-CM4";
    remoteBuild = true;
    deployable = false;
    whopper = false;
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
  };

  ## End ClockworkPi uConsole (CM4) ##

  ## ClockworkPi DevTerm (CM4) ##
  CLOCKWORK-DT-CM4 = mkHost rec {
    type = "nixos";
    address = "dial-in.rnet.rodriguez.org.uk";
    username = "dzrodriguez";
    hostPlatform = "aarch64-linux";
    hostname = "CLOCKWORK-DT-CM4";
    remoteBuild = true;
    deployable = false;
    whopper = false;
    hardwareModules = [ inputs.hardware.nixosModules.raspberry-pi-4 ];
    extraModules = [
      ../nix/24.05-compat.nix
      {
        environment.systemPackages = [
          inputs.agenix.packages.${hostPlatform}.default
          inputs.nix-alien.packages.${hostPlatform}.nix-alien
        ];
      }
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
  };
  ## End ClockworkPi DevTerm (CM4) ##
}
