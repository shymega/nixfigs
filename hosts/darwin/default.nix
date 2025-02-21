# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, ... }:
let
  genPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };

  inherit (inputs) self darwin;
  inherit (inputs.self) lib;
  genConfiguration =
    _hostname:
    { type
    , hostPlatform
    , hostname
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
    darwin.lib.darwinSystem {
      system = hostPlatform;
      pkgs = lib.my.genPkgs hostPlatform;
      modules = [ (../hosts/darwin + "/${hostname}") ];
      specialArgs = {
        hostType = type;
        system = hostPlatform;
        pkgs = lib.my.genPkgs hostPlatform;
        inherit lib;
        inherit (inputs)
          base16-schemes
          home-manager
          impermanence
          nix-index-database
          stylix
          ;
      };
    };
in
inputs.nixpkgs.lib.mapAttrs genConfiguration (inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "darwin") self.hosts)
