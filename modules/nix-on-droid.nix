# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  mkNixOnDroidConfig =
    { system ? "aarch64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/android/nix-on-droid
      ]
    , homeModules ? [
        mkHomeManagerConfig
        { }
      ]
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
  astro-slide = mkNixOnDroidConfig {
    hostname = "DZR-ASTRO-SLIDE";
  };
}
