{ lib, inputs, nixpkgs, nixpkgs-unstable, nixos-hardware, impermanence
, nix-colors, nix-on-droid, nixos-wsl, sops-nix, nix-alien, emacs-overlay
, doom-emacs, home-manager, ... }:
let
  pkgs = import nixpkgs { config.allowUnfree = true; };

  lib = nixpkgs.lib;
in {
  neo-linux = lib.nixosSystem {
    specialArgs = { inherit inputs; };
    system = "x86_64-linux";
    modules = [
      ./neo-linux
      ./configuration.nix
      ../common

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

  trinity-linux = lib.nixosSystem {
    specialArgs = { inherit inputs; };
    system = "x86_64-linux";
    modules = [
      ./trinity-linux
      ./configuration.nix
      ../common

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

  nixos-dev-vm-cloud = lib.nixosSystem {
    specialArgs = { inherit inputs; };
    system = "x86_64-linux";
    modules = [
      ./nixos-dev-vm-cloud
      ./configuration.nix
      ../common

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
