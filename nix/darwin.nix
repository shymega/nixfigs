# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

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
    , homeModules ? [ mkHomeManagerConfig { } ]
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
        { environment.systemPackages = [ inputs.agenix.defaultPackage.${system} ]; }
      ] ++ baseModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs; };
    };

  mkHomeManagerConfig =
    { usePkgs ? true
    , extraModules ? [
      ]
    , specialArgs ? [{ inherit self inputs; }]
    }:
    inputs.home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = usePkgs;
        useUserPackages = usePkgs;
        sharedModules = [
          inputs.agenix.homeManagerModules.default
        ] ++ extraModules;
        extraSpecialArgs = specialArgs;
      };
    };

in
{
  ### macOS (including Cloud/Local) machines ###
  ### End macOS (including Cloud/Local) machines ###
}
