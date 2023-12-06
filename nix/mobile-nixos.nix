{ self, inputs, ... }:
let
  mkMobileNixOSConfig =
    { system ? "aarch64-linux"
    , hostname ? "UNDEFINED-HOSTNAME"
    , nixpkgs ? inputs.nixpkgs
    , baseModules ? [
        ../common/android/mobile-nixos
        ../common/core
      ]
    , mobileNixosModules ? [ ]
    , homeModules ? [ ]
    , extraModules ? [ ]
    }: inputs.nixpkgs.lib.nixosSystem {
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
        (../hosts/android/mobile-nixos + "/${hostname}")
      ] ++ baseModules ++ homeModules ++ extraModules;
      extraSpecialArgs = { inherit self inputs nixpkgs; };
    };
in
{ }
