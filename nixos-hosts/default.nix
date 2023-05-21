{ lib, inputs, nixpkgs, nixpkgs-unstable, nixos-hardware, impermanence
, nix-colors, nix-on-droid, nixos-wsl, sops-nix, nix-alien, emacs-overlay
, doom-emacs, home-manager, ... }:
let
  pkgs = import nixpkgs {
    config.allowUnfree = true;
    system = "x86_64-linux";
  };

  lib = nixpkgs.lib;
in {
  NEO-LINUX = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      (import ./NEO-LINUX)
      (import ./configuration.nix)
      (import ../common)

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.dzrodriguez = {
          imports = [ ../home-manager/home.nix ];
        };
      }
    ];
  };

  TRINITY-LINUX = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      (import ./TRINITY-LINUX)
      (import ./configuration.nix)
      (import ../common)

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.dzrodriguez = {
          imports = [ ../home-manager/home.nix ];
        };
      }
    ];
  };

  LINK-LINUX = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      (import ./LINK-LINUX)
      (import ./configuration.nix)
      (import ../common)

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.dzrodriguez = {
          imports = [ ../home-manager/home.nix ];
        };
      }
    ];
  };

}
