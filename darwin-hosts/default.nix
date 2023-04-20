{ lib, inputs, nixpkgs, nixpkgs-unstable, nixos-hardware, impermanence
, nix-colors, nix-on-droid, nixos-wsl, sops-nix, nix-alien, emacs-overlay
, doom-emacs, home-manager, ... }: {
  mac-vm = darwin.lib.darwinSystem {
    system = "x86_64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      ./mac-vm/configuration.nix

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.dzrodriguez = import ../home-manager/home.nix;
      }
    ];
  };
}
