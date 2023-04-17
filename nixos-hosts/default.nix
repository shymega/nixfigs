{ lib, inputs, nixpkgs, nixpkgs-unstable, nixos-hardware, impermanence, nix-colors, nix-on-droid, nixos-wsl, sops-nix, nix-alien, emacs-overlay, doom-emacs, home-manager, ... }:
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
        home-manager.extraSpecialArgs = { inherit inputs doom-emacs; };
        home-manager.users.dzrodriguez = { imports = [ ../users/home.nix ]; };
      }
    ];
  };
}
