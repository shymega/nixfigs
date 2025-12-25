# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  description = "Dom's Nixified Flake";

  outputs = inputs: let
    inherit (inputs) self;
    rolesModule = import ./nix-support/roles.nix;
    systemsModule = import ./nix-support/systems.nix {inherit inputs;};
    hydraModule = import ./nix-support/hydra.nix {inherit self inputs;};
    githubActionsModule = import ./nix-support/github-actions.nix {
      inherit self inputs systemsModule;
    };
    buildsModule = import ./nix-support/builds.nix {inherit self inputs;};
    inherit (systemsModule) treefmtSystems forEachSystem;
    treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs treefmtSystems (system: f inputs.nixpkgs.legacyPackages.${system});
    treeFmtEval = treeFmtEachSystem (
      pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./nix-support/formatter.nix
    );
  in {
    inherit (rolesModule) roles;
    inherit (rolesModule) utils;
    nixpkgs-config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
      allowBroken = false;
      allowInsecurePredicate = pkg:
        builtins.elem (inputs.nixpkgs.lib.getName pkg) [
          # Add specific packages that need to be allowed here
          # Example: "package-name"
        ];
    };
    overlays = import ./overlays {
      inherit inputs;
      inherit (inputs.nixpkgs) lib;
    };
    deploy = import ./nix-support/deploy.nix {inherit self inputs;};
    homeConfigurations = import ./hosts/homes {inherit inputs;};
    nixosConfigurations = import ./hosts/nixos {inherit self inputs;};
    darwinConfigurations = import ./hosts/darwin {inherit self inputs;};
    hosts = with builtins; let
      lak = list:
        listToAttrs (
          map (v: {
            name = v.hostname or "home-manager-cfg";
            value = v;
          })
          list
        );
      raw = import ./hosts {inherit self inputs;};
    in
      lak (
        map (
          v:
            import v {
              inherit self inputs;
              inherit (raw) genPkgs mkHost;
            }
        )
        raw.enabled
      );
    packages = let
      inherit (inputs.shypkgs-public) forAllSystems;
    in
      forAllSystems (
        system:
          inputs.shypkgs-public.packages.${system}
          // {
            totp = inputs.nixpkgs.legacyPackages.${system}.callPackage ./packages/totp {};
          }
      );

    inherit (hydraModule) hydraJobs;

    formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);

    devShells = let
      inherit (systemsModule) devshellSystems forDevSystems;
    in
      forDevSystems (system: {
        default = import ./nix-support/devshell.nix {
          inherit inputs self system;
        };
      });

    checks = let
      inherit (systemsModule) checkSystems forDevSystems;
    in
      builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib
      // treeFmtEachSystem (pkgs: {
        formatting = treeFmtEval.${pkgs}.config.build.wrapper;
      })
      // forDevSystems (system: {
        pre-commit-check = import ./nix-support/checks.nix {
          inherit inputs system self;
        };
      });

    inherit (githubActionsModule) githubActions;

    inherit (buildsModule) builds;
  };

  inputs = {
    # Core Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixpkgs-shymega.url = "github:shymega/nixpkgs?ref=shymega/staging";
    flake-utils.url = "github:numtide/flake-utils";

    # NixOS modules and hardware
    hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    hardware-shymega = {
      url = "github:shymega/nixos-hardware?ref=shymega";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian-nixos = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home management
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS support
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Security and secrets
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote?ref=v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    devenv = {
      url = "github:cachix/devenv?ref=latest";
      inputs.nixpkgs.follows = "nixpkgs";
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
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deployment
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System customization
    stylix = {
      url = "github:danth/stylix?ref=release-25.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    base16-schemes = {
      url = "github:SenchoPens/base16.nix";
    };

    # Desktop environment
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.52.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # Prevents version mismatch.
    };
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces?rev=8f0c875a5ba9864b1267e74e6f03533d18c2bca0";
      inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    };

    # Package repositories
    chaotic = {
      url = "github:chaotic-cx/nyx?ref=nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix alternatives
    # Lix is included in Nixpkgs.
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Specialized tools
    ucodenix = {
      url = "github:e-tho/ucodenix";
    };
    nm2nix = {
      url = "github:Janik-Haag/nm2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal packages and configs
    shypkgs-private = {
      url = "github:shymega/shypkgs-private-dummy";
    };
    shypkgs-public = {
      url = "github:shymega/shypkgs-public";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shyemacs-cfg = {
      url = "github:shymega/emacs-cfg";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Personal utilities
    dzr-taskwarrior-recur = {
      url = "github:shymega/dzr-taskwarrior-recur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Editor configs
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Shell plugins
    op-password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private configs (dummy repos)
    nixfigs-virtual-private.url = "github:shymega/nixfigs-virtual-private-dummy";
    nixfigs-work.url = "github:shymega/nixfigs-work-dummy";
    nixfigs-private.url = "github:shymega/nixfigs-private-dummy";
    nixfigs-secrets.url = "github:shymega/nixfigs-secrets";
    nixfigs-networks.url = "github:shymega/nixfigs-networks-dummy";

    # Non-flake inputs
    nixos-flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    nixfigs-doom-emacs-personal = {
      url = "github:shymega/nixfigs-doom-emacs";
      flake = false;
    };
  };
}
