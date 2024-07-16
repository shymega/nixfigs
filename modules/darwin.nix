# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, pkgs }:
let
  inherit (pkgs.lib.lists) singleton;
  mkDarwinConfig =
    { system ? "aarch64-darwin"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/darwin
      ]
    , homeModules ? [
        mkHomeManagerConfig
        { }
      ]
    , extraModules ? [ ]
    }: inputs.nix-darwin.lib.darwinSystem {
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
      home-manager-path = inputs.home-manager.outPath;
      modules = [
        inputs.agenix.nixosModules.default
        ../secrets
        (../hosts/darwin + "/${hostname}")
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
  ### macOS (including Cloud/Local) machines ###

  NEO-MAC = mkDarwinConfig {
    system = "x86_64-darwin";
    hostname = "NEO-MAC";
    extraModules = [
      ../hosts/darwin/neo
    ];
    homeModules = [
      mkHomeManagerConfig
      {
        extraModules = singleton
          { users.dzrodriguez = import ../users/home.nix; };
      }
    ];
  };

  ### End macOS (including Cloud/Local) machines ###
}
