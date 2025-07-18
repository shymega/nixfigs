# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
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
  inherit (inputs) self;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  genConfiguration =
    hostname:
    {
      type,
      hostPlatform,
      username,
      ...
    }:
    let
      lib = inputs.nixpkgs.lib.extend (
        final: prev:
        {
          inherit (inputs.home-manager.lib) hm;
        }
        // (import "${self}/lib" {
          pkgs = genPkgs hostPlatform;
          inherit self inputs;
        })
      );
    in
    homeManagerConfiguration {
      pkgs = genPkgs hostPlatform;
      modules = with inputs; [
        "${self}/src/homes/${username}@${hostPlatform}"
        agenix.homeManagerModules.default
        nix-doom-emacs-unstraightened.hmModule
        nix-index-database.hmModules.nix-index
      ];
      extraSpecialArgs = {
        hostType = type;
        system = hostPlatform;
        inherit
          inputs
          username
          self
          lib
          ;
      };
    };
in
inputs.nixpkgs.lib.mapAttrs genConfiguration (
  inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "home-manager") self.hosts
)
