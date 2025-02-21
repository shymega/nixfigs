{ self, inputs, ... }:
let
  mkNixOnDroidConfig =
    { system ? "aarch64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/android
        ../common/core
      ]
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
      modules = [ ../secrets (../hosts/android + "/${hostname}") ] ++ baseModules ++ extraModules;
      extraSpecialArgs = { inherit self inputs nixpkgs; };
    };
in
{ }
