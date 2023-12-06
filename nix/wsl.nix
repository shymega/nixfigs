# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  mkWslConfig =
    { system ? "x86_64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/wsl
        ../common/core
      ]
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
          allowUnsupportedSystem = true;
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
        (../hosts/wsl + "/${hostname}")
      ] ++ baseModules ++ homeModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs; };
    };
in
{ }
