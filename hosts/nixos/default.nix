# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs
, self
, ...
}:
let
  genPkgs = system: overlays:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays ++ overlays;
      config = self.nixpkgs-config;
    };
  genConfiguration =
    hostname:
    { address
    , hostPlatform
    , type
    , extraModules
    , deployable
    , monolithConfig
    , overlays
    , hostRole
    , hardwareModules
    , baseModules
    , ...
    }:
    let
      lib = inputs.nixpkgs.lib.extend
        (
          _final: prev: {
            my = import ../../lib {
              inherit self inputs;
              lib = prev;
              pkgs = genPkgs hostPlatform overlays;
            };
          }
        ) // inputs.nixpkgs.lib;
    in
    inputs.nixpkgs.lib.nixosSystem rec {
      pkgs = genPkgs hostPlatform overlays;
      modules =
        baseModules ++ [
          (./configs + "/${hostname}")
          ../../modules/nixos/generators.nix
        ]
        ++ extraModules ++ hardwareModules
        ++ (lib.optional monolithConfig (import ./monolith.nix));
      specialArgs = {
        hostAddress = address;
        hostType = type;
        pkgs = genPkgs hostPlatform overlays;
        system = hostPlatform;
        inherit
          self
          inputs
          lib
          hostRole
          deployable
          hostname
          hostPlatform
          ;
      };
    };
in
inputs.nixpkgs.lib.mapAttrs genConfiguration (inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "nixos") self.hosts)
