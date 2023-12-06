# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ self, inputs, ... }:
let
  mkNixOnDroidConfig =
    { system ? "aarch64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/android/nix-on-droid
      ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }: inputs.nix-on-droid.lib.nixOnDroidConfiguration {
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
      home-manager-path = inputs.home-manager.outPath;
      modules = [
        inputs.agenix.nixosModules.default
        ../secrets
        (../hosts/android/nix-on-droid + "/${hostname}")
      ] ++ baseModules ++ homeModules ++ extraModules;
      extraSpecialArgs = { inherit self inputs nixpkgs; };
    };
in
{
  astro-slide = mkNixOnDroidConfig {
    hostname = "DZR-ASTRO-SLIDE";
    homeModules = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          sharedModules = [
            inputs.agenix.homeManagerModules.default
          ];
          extraSpecialArgs = { inherit self inputs; };
        };
      }
    ];
  };
}
