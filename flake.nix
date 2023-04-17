{
  description =
    "Dom (shymega)'s Nix(OS) Flake configuration, split by 'hosts'.";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.11"; };

    nixpkgs-unstable = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    impermanence = { url = "github:nix-community/impermanence"; };
    nix-colors = { url = "github:misterio77/nix-colors"; };

    nix-on-droid = {
      url = "github:t184256/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      flake = false;
    };

    doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, nixos-hardware
    , impermanence, nix-colors, nix-on-droid, nixos-wsl, sops-nix, nix-alien
    , nix-darwin, emacs-overlay, doom-emacs, home-manager, ... }:
    let user = "dzrodriguez";
    in {
      nixosConfigurations = (import ./nixos-hosts {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs nixpkgs-unstable nixos-hardware impermanence nix-colors nix-on-droid nixos-wsl sops-nix nix-alien emacs-overlay doom-emacs home-manager;
      });

      darwinConfigurations = (import ./darwin-hosts {
        inherit (nixpkgs) lib;
        inherit inputs nix-darwin nixpkgs nixpkgs-unstable nixos-hardware
          impermanence nix-colors nix-on-droid nixos-wsl sops-nix nix-alien
          emacs-overlay doom-emacs home-manager;
      });

      homeConfigurations = (import ./users {
        inherit (nixpkgs) lib;
        inherit inputs nix-darwin nixpkgs nixpkgs-unstable nixos-hardware
          impermanence nix-colors nix-on-droid nixos-wsl sops-nix nix-alien
          emacs-overlay doom-emacs home-manager;
      });
    };
}
