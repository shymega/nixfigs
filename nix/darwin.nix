# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ self, inputs, ... }:
let
  mkDarwinConfig =
    { system ? "x86_64-darwin"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/darwin
        ../common/core
      ]
    , hardwareModules ? [ ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }: inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      pkgs = import nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
        config = {
          allowUnfree = true;
          allowBroken = false;
          allowInsecure = false;
          allowUnsupportedSystem = false;
        };
      };
      modules = [
        ../secrets
        (../hosts/darwin + "/${hostname}")
        inputs.agenix.darwinModules.default
        inputs.nix-ld.nixosModules.nix-ld
        inputs.nix-index-database.nixosModules.nix-index
        { environment.systemPackages = [ inputs.agenix.defaultPackage.${system} ]; }
      ] ++ baseModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs; };
    };
in
{
  ### macOS (including Cloud/Local) machines ###
  ### End macOS (including Cloud/Local) machines ###
}
