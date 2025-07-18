# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

# GitHub Actions matrix configuration
{
  self,
  inputs,
  systemsModule,
  ...
}: let
  inherit (systemsModule) systemToPlatform;
  inherit (inputs.nixpkgs.lib.attrsets) filterAttrs mapAttrsToList;
in {
  githubActions.matrix = let
    nixosConfigs = {
      include = with builtins; let
        pred = n: v: let
          isWorkMachine = v:
            if hasAttr "nixfigs.meta.rolesEnabled" v.config
            then elem "work" v.config.nixfigs.meta.rolesEnabled
            else false;
          notUnsupportedSystem = let
            unsupportedSystems = [
              "armv6l-linux"
              "armv7l-linux"
              "riscv64-linux"
            ];
          in
            sys: any (x: x == sys) unsupportedSystems;
        in
          !isWorkMachine v && !notUnsupportedSystem v.pkgs.system;
      in
        mapAttrsToList (n: v: {
          hostName = n;
          platform = systemToPlatform v.pkgs.system;
          inherit (v.pkgs) system;
        }) (filterAttrs pred self.nixosConfigurations);
    };
  in
    nixosConfigs;
}