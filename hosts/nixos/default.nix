# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs
, self
, ...
}:
let
  genPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
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
              pkgs = genPkgs hostPlatform;
            };
          }
        ) // inputs.nixpkgs.lib;
    in
    inputs.nixpkgs.lib.nixosSystem {
      pkgs = lib.my.genPkgs hostPlatform;
      modules =
        baseModules ++ [
          (../../secrets/system)
          (./configs + "/${hostname}")
          ../../modules/nixos/generators.nix
        ]
        ++ extraModules ++ hardwareModules ++ (lib.optional monolithConfig (import ./monolith.nix));
      specialArgs = {
        hostAddress = address;
        hostType = type;
        pkgs = genPkgs hostPlatform;
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
