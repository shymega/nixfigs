# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  mkMobileNixOSConfig =
    { system ? "aarch64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/android/mobile-nixos
        ../common/core
      ]
    , mobileNixosModules ? [ ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }: inputs.nixpkgs.lib.nixosSystem {
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
        (../hosts/android/mobile-nixos + "/${hostname}")
      ] ++ baseModules ++ homeModules ++ extraModules;
      extraSpecialArgs = { inherit self inputs nixpkgs; };
    };
in
{ }
