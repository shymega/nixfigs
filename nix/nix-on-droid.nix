{ self, inputs, ... }:
let
  mkNixOnDroidConfig =
    { system ? "aarch64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/android/nix-on-droid
        ../common/core
      ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }: inputs.nix-on-droid.lib.nixOnDroidConfiguration {
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
      home-manager-path = inputs.home-manager.outPath;
      modules = [ ../secrets (../hosts/android/nix-on-droid + "/${hostname}") ] ++ baseModules ++ homeModules ++ extraModules;
      extraSpecialArgs = { inherit self inputs nixpkgs; };
    };
in
{
  astro-slide = mkNixOnDroidConfig {
    hostname = "DZR-ASTRO-SLIDE";
    homeModules = [
      inputs.home-manager
      {
        backupFileExtension = "hm-bak";
        useGlobalPkgs = true;

        config =
          { config, lib, pkgs, ... }:
          {
            # Read the changelog before changing this value
            home.stateVersion = "23.11";
          };
      }
    ];
  };
}
