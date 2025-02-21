# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  description = "@shymega's system Flake";

  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.dataaturservice.se/spectrum"
      "https://cache.nixos.org/"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://pre-commit-hooks.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "spectrum-os.org-1:rnnSumz3+Dbs5uewPlwZSTP0k3g/5SRG4hD7Wbr9YuQ="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-shymega.url = "github:shymega/nixpkgs/master";
    nixfigs-priv.url = "github:shymega/nixfigs-priv/main";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    dwl-source.url = "https://codeberg.org/dwl/dwl";
    dwl-source.flake = false;
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
    hardware.url = "github:shymega/nixos-hardware/24.05-compat-add-1";
    impermanence.url = "github:nix-community/impermanence";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        darwin.follows = "nix-darwin";
      };
    };
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-index-database.follows = "nix-index-database";
      };
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-compat.follows = "flake-compat";
      };
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    wemod-launcher.url = "github:shymega/wemod-launcher/refactor-shymega";
    deckcheatz.url = "github:deckcheatz/deckcheatz/develop";
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  outputs = { self, ... } @ inputs:
    let
      inherit (inputs.nixpkgs) lib;

      # TODO: Add RISC-V - specific Cache, and Nixpkgs. For Pine64/other RISC-V SoCs.
      forAllUpstreamSystems = inputs.nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      pkgs = forAllUpstreamSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays ++ [
            (import ./pkgs/dwl/dwl.nix)
          ];
          config = {
            allowUnfree = true;
            allowBroken = false;
            allowInsecure = false;
            allowUnsupportedSystem = false;
          };
        });
    in
    rec {
      overlays = import ./modules/overlays.nix { inherit self inputs lib; };
      devShells = forAllUpstreamSystems (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = builtins.attrValues self.overlays;
            config = {
              allowUnfree = true;
              allowBroken = false;
              allowInsecure = false;
              allowUnsupportedSystem = false;
            };
          };
        in
        import ./modules/devshell.nix { inherit inputs pkgs self system; });

      nixosConfigurations = (import ./modules/nixos.nix { inherit self inputs pkgs; }) // (import ./modules/wsl.nix { inherit self inputs pkgs; }) // (import ./modules/mobile-nixos.nix { inherit self inputs pkgs; }) // inputs.nixfigs-priv.outputs.nixosConfigurations;
      homeConfigurations = import ./modules/home-manager.nix { inherit self inputs pkgs; };
      nixOnDroidConfigurations = import ./modules/nix-on-droid.nix { inherit self inputs pkgs; };
      darwinConfigurations = import ./modules/darwin.nix { inherit self inputs pkgs; };
      secrets-system = import ./secrets/system;
      secrets = secrets-system;
      secrets-user = import ./secrets/user;
      common-core = import ./common/core { inherit self inputs pkgs; };
      common-nixos = import ./common/nixos { inherit self inputs pkgs; };
    };
}
