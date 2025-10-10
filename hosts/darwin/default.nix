# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  self,
  inputs,
  ...
}: let
  genPkgs = system: overlays:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays ++ overlays;
      config = self.nixpkgs-config;
    };
  genConfiguration = hostname: {
    address,
    hostPlatform,
    type,
    username,
    deployable,
    overlays,
    embedHm,
    hostRoles,
    ...
  }: let
    lib = inputs.nixpkgs.lib.extend (
      final: prev:
        (import "${self}/lib" {
          pkgs = genPkgs hostPlatform overlays;
          inherit self inputs;
        })
        // inputs.home-manager.lib.hm
        // inputs.nixpkgs.lib
    );
  in
    inputs.nix-darwin.lib.darwinSystem {
      system = hostPlatform;
      pkgs = genPkgs hostPlatform overlays;
      modules = [
        "${self}/src/hosts/${hostname}@${hostPlatform}"
        "${self}/src/modules/core"
        "${self}/src/modules/darwin"
      ];
      specialArgs = {
        hostAddress = address;
        hostType = type;
        system = hostPlatform;
        inherit
          deployable
          embedHm
          hostPlatform
          hostRoles
          hostname
          inputs
          lib
          self
          username
          ;
      };
    };
in
  inputs.nixpkgs.lib.mapAttrs genConfiguration (
    inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "darwin") self.hosts
  )
