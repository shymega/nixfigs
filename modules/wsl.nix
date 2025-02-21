# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  mkNixosWslConfig =
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
        inputs.nixos-wsl.nixosModules.default
        inputs.chaotic.nixosModules.default
        ../secrets/system
        (../hosts/wsl + "/${hostname}")
      ] ++ baseModules ++ hardwareModules ++ homeModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs hostname system; };
    };
in
{
  ### WSL ###

  MORPHEUS-WSL = mkNixosWslConfig rec {
    hostname = "MORPHEUS-WSL";
    system = "x86_64-linux";
    extraModules = [
      ({ lib, ... }: {
        # Backward-compat for 24.05, can be removed after we drop 24.05 support
        imports = lib.optionals (lib.versionOlder lib.version "24.11pre") [
          (lib.mkAliasOptionModule [ "hardware" "graphics" "extraPackages32" ] [ "hardware" "opengl" "extraPackages32" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "enable32Bit" ] [ "hardware" "opengl" "driSupport32Bit" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "package" ] [ "hardware" "opengl" "package" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "package32" ] [ "hardware" "opengl" "package32" ])
        ];
      })
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }
      ../hosts/nixos/configuration.nix
    ];
  };

  NEO-WSL = mkNixosWslConfig rec {
    hostname = "NEO-WSL";
    system = "x86_64-linux";
    extraModules = [
      ({ lib, ... }: {
        # Backward-compat for 24.05, can be removed after we drop 24.05 support
        imports = lib.optionals (lib.versionOlder lib.version "24.11pre") [
          (lib.mkAliasOptionModule [ "hardware" "graphics" "extraPackages32" ] [ "hardware" "opengl" "extraPackages32" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "enable32Bit" ] [ "hardware" "opengl" "driSupport32Bit" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "package" ] [ "hardware" "opengl" "package" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "package32" ] [ "hardware" "opengl" "package32" ])
        ];
      })
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }
      ../hosts/nixos/configuration.nix
    ];
  };

  TWINS-WSL = mkNixosWslConfig rec {
    hostname = "TWINS-WSL";
    system = "x86_64-linux";
    extraModules = [
      ({ lib, ... }: {
        # Backward-compat for 24.05, can be removed after we drop 24.05 support
        imports = lib.optionals (lib.versionOlder lib.version "24.11pre") [
          (lib.mkAliasOptionModule [ "hardware" "graphics" "extraPackages32" ] [ "hardware" "opengl" "extraPackages32" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "enable32Bit" ] [ "hardware" "opengl" "driSupport32Bit" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "package" ] [ "hardware" "opengl" "package" ])
          (lib.mkAliasOptionModule [ "hardware" "graphics" "package32" ] [ "hardware" "opengl" "package32" ])
        ];
      })
      {
        environment.systemPackages = [
          inputs.agenix.packages.${system}.default
          inputs.nix-alien.packages.${system}.nix-alien
        ];
      }
      ../hosts/nixos/configuration.nix
    ];
  };

  ### End WSL ###
}
