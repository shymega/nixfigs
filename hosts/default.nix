# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  self,
  inputs,
  ...
}: let
  genPkgs = system:
    import inputs.nixpkgs {
      inherit system;
      overlays = builtins.attrValues self.overlays;
      config = self.nixpkgs-config;
    };
  mkHost = {
    type ? "nixos",
    address ? "${hostname}.dzr.devices.rnet.rodriguez.org.uk",
    hostname ? null,
    hostPlatform ? "x86_64-linux",
    username ? "dzrodriguez",
    baseModules ?
      with inputs; [
        {
          environment.systemPackages = with inputs; [
            sops-nix.packages.${hostPlatform}.default
            nix-alien.packages.${hostPlatform}.nix-alien
          ];
        }
        sops-nix.nixosModules.default
<<<<<<< HEAD
        chaotic.nixosModules.default
        lix-module.nixosModules.default
=======
        determinate.nixosModules.default
>>>>>>> 9aa18130 (fix: Fix `pkgs.system` usages)
      ],
    overlays ? [],
    hostRoles ? [],
    hardwareModules ? [],
    extraModules ? [],
    pubkey ? null,
    remoteBuild ? false,
    deployable ? false,
    embedHm ? true,
    enableFoundationModules ? true,
  }: let
    inherit (inputs.nixpkgs.lib.strings) hasSuffix;
  in
    if type == "nixos"
    then assert (hasSuffix "linux" hostPlatform); {
      inherit
        address
        baseModules
        deployable
        embedHm
        extraModules
        hardwareModules
        hostPlatform
        hostRoles
        hostname
        overlays
        pubkey
        remoteBuild
        type
        username
        genPkgs
        enableFoundationModules
        ;
    }
    else if type == "darwin"
    then assert (hasSuffix "darwin" hostPlatform); {
      inherit
        address
        baseModules
        deployable
        extraModules
        hardwareModules
        hostPlatform
        hostname
        pubkey
        remoteBuild
        type
        username
        genPkgs
        ;
    }
    else if type == "home-manager"
    then assert username != null; {
      inherit type hostPlatform username;
    }
    else throw "unknown host type '${type}'";
in {
  inherit genPkgs mkHost;
  enabled = let
    inherit (inputs.nixpkgs.lib.filesystem) listFilesRecursive;
  in
    listFilesRecursive ./declarations/enabled.d;
}
