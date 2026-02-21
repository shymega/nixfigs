# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  self,
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
    baseModules,
    deployable,
    embedHm,
    enableFoundationModules,
    extraModules,
    hardwareModules,
    hostPlatform,
    hostRoles,
    overlays,
    pubkey,
    type,
    username,
    ...
  }: let
    lib = inputs.nixpkgs.lib.extend (
      final: prev:
        (import "${self}/lib" {
          pkgs = genPkgs hostPlatform overlays;
          inherit self inputs;
        })
        // {
          inherit (inputs.home-manager.lib) hm;
        }
    );
  in
    inputs.nixpkgs.lib.nixosSystem rec {
      pkgs = genPkgs hostPlatform overlays;
      modules =
        baseModules
        ++ (with inputs; [
          "${self}/src/systems/${hostname}@${hostPlatform}"
          nixfigs-secrets.system
          {nixpkgs.pkgs = pkgs;}
        ])
        ++ (lib.optionals enableFoundationModules [
          "${self}/src/modules/core"
          "${self}/src/modules/nixos"
          "${self}/src/modules/nixos/installer"
        ])
        ++ extraModules
        ++ hardwareModules
        ++ (lib.optionals embedHm [
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "hm.bak";
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = "${self}/src/homes/${username}@${hostPlatform}";
              extraSpecialArgs = {
                inherit
                  deployable
                  embedHm
                  hostPlatform
                  hostRoles
                  hostname
                  inputs
                  lib
                  self
                  specialArgs
                  username
                  ;
              };
            };
          }
        ]);
      specialArgs = {
        hostAddress = address;
        hostType = type;
        inherit lib;
        system = hostPlatform;
        inherit
          deployable
          embedHm
          hostPlatform
          hostRoles
          hostname
          inputs
          pubkey
          self
          specialArgs
          username
          ;
      };
    };
in
  inputs.nixpkgs.lib.mapAttrs genConfiguration (
    inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "nixos") self.hosts
  )
