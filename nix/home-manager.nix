# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, inputs, ... }:

let
  mkHomeConfig =
    { username ? "dzrodriguez"
    , system ? "x86_64-linux"
    , hostname ? "UNDEFINED-HOST"
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
        inputs.agenix.homeManagerModules.default
        inputs.nix-index-database.hmModules.nix-index
      ] ++ baseModules ++ extraHomeModules;
      extraSpecialArgs = { inherit self inputs nixpkgs username system hostname; };
    };
in
{
  "dzrodriguez@NEO-LINUX" = mkHomeConfig {
    username = "dzrodriguez";
    system = "x86_64-linux";
    hostname = "NEO-LINUX";
    extraHomeModules = [
      ../users
    ];
  };
  "dzrodriguez@TRINITY-LINUX" = mkHomeConfig {
    username = "dzrodriguez";
    system = "x86_64-linux";
    hostname = "TRINITY-LINUX";
    extraHomeModules = [
      ../users
    ];
  };
  "dzrodriguez@TWINS-LINUX" = mkHomeConfig {
    username = "dzrodriguez";
    system = "x86_64-linux";
    hostname = "TWINS-LINUX";
    extraHomeModules = [
      ../users
    ];
  };
}
