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
    hostPlatform,
    type,
    extraModules,
    username,
    deployable,
    overlays,
    embedHm,
    hostRoles,
    hardwareModules,
    baseModules,
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
      system = hostPlatform;
      pkgs = genPkgs hostPlatform overlays;
      modules =
        baseModules
        ++ (with inputs; [
          "${self}/src/systems/nixosConfigurations/${hostname}@${hostPlatform}"
          agenix.nixosModules.default
          chaotic.nixosModules.default
          nixfigs-secrets.system
          lix-module.nixosModules.default
          "${self}/src/modules/core"
          "${self}/src/modules/nixos"
          "${self}/src/modules/nixos/iso"
        ])
        ++ [
          ({config, ...}: {
            users.users."dzrodriguez" = {
              password = "changeme";
              home = "/home/dzrodriguez";
              isNormalUser = true;
              extraGroups = ["wheel"];
            };
          })
        ]
        ++ extraModules
        ++ hardwareModules
        ++ (lib.optional embedHm inputs.home-manager.nixosModules.home-manager)
        ++ (lib.optional embedHm {
          home-manager = {
            useGlobalPkgs = true;
            backupFileExtension = "hm.bak";
            useUserPackages = true;
            users.${username} = "${self}/src/homes/homeConfigurations/${username}@${hostPlatform}";
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
              system = hostPlatform;
            };
          };
        });
      specialArgs = {
        hostAddress = address;
        hostType = type;
        pkgs = genPkgs hostPlatform overlays;
        system = hostPlatform;
        inherit lib;
        inherit
          self
          inputs
          embedHm
          username
          hostRoles
          specialArgs
          deployable
          hostname
          hostPlatform
          ;
      };
    };
in
  inputs.nixpkgs.lib.mapAttrs genConfiguration (
    inputs.nixpkgs.lib.filterAttrs (_: host: host.type == "nixos") self.hosts
  )
