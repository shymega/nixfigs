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
      libx = import ../../lib {
        inherit self inputs;
        inherit (inputs.nixpkgs) lib;
        pkgs = genPkgs hostPlatform;
      };
      inherit (inputs.nixpkgs) lib;
    in
    darwin.lib.darwinSystem {
      system = hostPlatform;
      pkgs = libx.genPkgs hostPlatform;
      modules = [ (../hosts/darwin + "/${hostname}") ];
      specialArgs = {
        hostType = type;
        system = hostPlatform;
        pkgs = libx.genPkgs hostPlatform;
        inherit lib libx;
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
