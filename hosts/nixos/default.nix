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
    , username
    , deployable
    , monolithConfig
    , overlays
    , embedHm
    , hostRole
    , hardwareModules
    , baseModules
    , ...
    }:
    let
      libx = import ../../lib {
        inherit self inputs;
        inherit (inputs.nixpkgs) lib;
        pkgs = genPkgs hostPlatform overlays;
      };
      inherit (inputs.nixpkgs) lib;
    in
    inputs.nixpkgs.lib.nixosSystem rec {
      system = hostPlatform;
      pkgs = genPkgs hostPlatform overlays;
      modules =
        baseModules ++ [
          (./configs + "/${hostname}")
          ../../modules/nixos/generators.nix
        ]
        ++ extraModules ++ hardwareModules
        ++ (lib.optional embedHm inputs.home-manager.nixosModules.home-manager)
        ++ (lib.optional embedHm {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ../../homes/configs;
            extraSpecialArgs = {
              inherit self
                inputs
                embedHm
                username
                hostRole
                specialArgs
                deployable
                hostname
                libx
                hostPlatform;
              system = hostPlatform;
            };
          };
        })
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
          libx
          embedHm
          username
          hostRole
          specialArgs
          deployable
          hostname
          hostPlatform
          ;
      };
    };
in
inputs.nixpkgs.lib.mapAttrs genConfiguration (inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "nixos") self.hosts)
