# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:

let
  mkHomeConfig =
    { username ? "dzrodriguez"
    , system ? "x86_64-linux"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/home-manager
      ]
    , extraHomeModules ? [ ]
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
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
        inputs.nix-index-database.hmModules.nix-index
        inputs.agenix.homeManagerModules.default
      ] ++ baseModules ++ extraHomeModules;
      extraSpecialArgs = { inherit self inputs nixpkgs username system; };
    };
in
{
  "dzrodriguez@NEO-LINUX" = mkHomeConfig {
    username = "dzrodriguez";
    system = "x86_64-linux";
    extraHomeModules = [
      ../users
    ];
  };
  "dzrodriguez@TRINITY-LINUX" = mkHomeConfig {
    username = "dzrodriguez";
    system = "x86_64-linux";
    extraHomeModules = [
      ../users
    ];
  };
  "dzrodriguez@TWINS-LINUX" = mkHomeConfig {
    username = "dzrodriguez";
    system = "x86_64-linux";
    extraHomeModules = [
      ../users
    ];
  };
}
