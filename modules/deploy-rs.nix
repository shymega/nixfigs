# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:
let
  mkDeployNode =
    { system ? "x86_64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/nixos
        ../common/core
      ]
    , hardwareModules ? [ ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }:
    inputs.nixpkgs.lib.nixosSystem {
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
        inputs.agenix.nixosModules.default
        {
          environment.systemPackages = [
            inputs.agenix.packages.${system}.default
            inputs.nix-alien.packages.${system}.nix-alien
            inputs.wemod-launcher.packages.${system}.default
            inputs.deckcheatz.packages.${system}.default
          ];
        }
        ../secrets/system
        (../hosts/nixos + "/${hostname}")
        (../hosts/nixos + "/${hostname}" + "/hardware-configuration.nix")
      ] ++ baseModules ++ hardwareModules ++ homeModules ++ extraModules;
      specialArgs = { inherit self inputs nixpkgs hostname system; };
    };
in
{
  imports = [ ./nixos.nix ./home-manager.nix ];
}
