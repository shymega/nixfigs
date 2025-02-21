# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  description = "shymega's Nix config";

  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.dataaturservice.se/spectrum"
      "https://cache.nixos.org/"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "spectrum-os.org-1:rnnSumz3+Dbs5uewPlwZSTP0k3g/5SRG4hD7Wbr9YuQ="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-23-05.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-shymega.url = "github:shymega/nixpkgs/master";
    nixfigs-priv.url = "github:shymega/nixfigs-priv/main";
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
    base16-schemes = {
      url = "github:tinted-theming/base16-schemes";
      flake = false;
    };
    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
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
        flake-utils.follows = "flake-utils";
        nix-index-database.follows = "nix-index-database";
        flake-compat.follows = "flake-compat";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        utils.follows = "flake-utils";
      };
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-23-05";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        pre-commit-hooks-nix.follows = "pre-commit-hooks";
      };
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
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
    mobile-nixos = {
      url = "github:NixOS/mobile-nixos";
      flake = false;
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... } @ inputs:
    let
      inherit (inputs.nixpkgs) lib;

      inherit (inputs.nixpkgs.stdenvNoCC) isDarwin;
      inherit (inputs.nixpkgs.stdenvNoCC) isLinux;
      isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
      isForeignNix = !isNixOS && isLinux && builtins.pathExists "/nix";
      homePrefix =
        if isDarwin then
          "/Users"
        else
          "/home";

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
          overlays = builtins.attrValues self.overlays;
          config = {
            allowUnfree = true;
            allowBroken = false;
            allowInsecure = false;
            allowUnsupportedSystem = false;
          };
        });
    in
    {
      overlays = import ./nix/overlay.nix { inherit self inputs lib; };
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
        import ./nix/devshell.nix { inherit inputs pkgs self system; });

      nixosConfigurations = (import ./nix/nixos.nix { inherit self inputs pkgs; }) // (import ./nix/wsl.nix { inherit self inputs pkgs; }) // (import ./nix/mobile-nixos.nix { inherit self inputs pkgs; }) // inputs.nixfigs-priv.outputs.nixosConfigurations;
      homeConfigurations = import ./nix/home-manager.nix { inherit self inputs pkgs; };
      nixOnDroidConfigurations = import ./nix/nix-on-droid.nix { inherit self inputs pkgs; };
      darwinConfigurations = import ./nix/darwin.nix { inherit self inputs pkgs; };
      secrets = import ./secrets;
      common-core = import ./common/core { inherit self inputs pkgs; };
      common-nixos = import ./common/nixos { inherit self inputs pkgs; };
    };
}
