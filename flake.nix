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
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
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
      url = "github:nix-community/home-manager?ref=release-25.05";
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
      url = "github:nix-community/lanzaboote?ref=v0.4.2";
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
      url = "github:danth/stylix?ref=release-25.05";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    base16-schemes = {
      url = "github:SenchoPens/base16.nix";
    };

    # Desktop environment
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.50.1";
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
      url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
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
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Specialized tools
    ucodenix = {
      url = "github:e-tho/ucodenix";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs?ref=stable";
      inputs.nixpkgs.follows = "nixpkgs";
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

<<<<<<< HEAD
    # Gaming
    deckcheatz = {
      url = "github:deckcheatz/deckcheatz";
      inputs.nixpkgs.follows = "nixpkgs";
=======
  outputs = {self, ...} @ inputs: let
    supportedSystems =
      inputs.snowfall-lib.inputs.flake-utils-plus.lib.defaultSystems
      ++ [
        "riscv64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
    enableLix = true;
  in
    inputs.snowfall-lib.mkFlake {
      inherit inputs supportedSystems;
      src = ./.;
      channels-config = {
        allowUnfree = true;
      };
      outputs-builder = channels: let
        system = channels.nixpkgs.system;
        treefmtConfig = import ./nix/formatter.nix;
        treefmtWrapper = inputs.treefmt-nix.lib.mkWrapper channels.nixpkgs treefmtConfig;
      in {
        formatter = treefmtWrapper;
        checks = {
          pre-commit-check = import ./nix/checks.nix {
            inherit self system inputs;
            inherit (channels.nixpkgs) lib;
          };
        };
        # devShell = import ./nix/devShell.nix {
        #  inherit self system;
        #  pkgs = channels.nixpkgs;
        # };
      };

      systems.modules.nixos = with inputs;
        [
        ]
        ++ (inputs.nixpkgs.lib.optional enableLix
          inputs.lix-module.nixosModules.default);

      # Configure Snowfall Lib, all of these settings are optional.
      snowfall = {
        # Tell Snowfall Lib to look in the `./nix/` directory for your
        # Nix files.
        root = ./src;

        # Choose a namespace to use for your flake's packages, library,
        # and overlays.
        namespace = "nixfigs";

        # Add flake metadata that can be processed by tools like Snowfall Frost.
        meta = {
          # A slug to use in documentation when displaying things like file paths.
          name = "nixfigs";

          # A title to show for your flake, typically the name.
          title = "Dom's Nixified Flake";
        };
      };
    }
    // {
      self = inputs.self;
      packages = let
        inherit (inputs.shypkgs-public) allSystems forAllSystems;
      in
        forAllSystems (system: inputs.shypkgs-public.packages.${system});
      hydraJobs = let
        inherit (inputs.nixpkgs.lib) isDerivation filterAttrs mapAttrs elem;
        notBroken = pkg: !(pkg.meta.broken or false);
        isDistributable = pkg: (pkg.meta.license or {redistributable = true;}).redistributable;
        hasPlatform = sys: pkg: elem sys (pkg.meta.platforms or [sys]);
        filterValidPkgs = sys: pkgs:
          filterAttrs (_: pkg:
            isDerivation pkg
            && hasPlatform sys pkg
            && notBroken pkg
            && isDistributable pkg)
          pkgs;
        getConfigTopLevel = _: cfg: cfg.config.system.build.toplevel;
        getActivationPackage = _: cfg: cfg.config.home.activationPackage;
      in {
        pkgs = mapAttrs filterValidPkgs self.packages;
        hosts = mapAttrs getConfigTopLevel self.nixosConfigurations;
        users = mapAttrs getActivationPackage self.homeConfigurations;
        inherit (self.builds) sdImages isoImages;
      };

      githubActions.matrix = with builtins; let
        systemToPlatform = system: let
          inherit (inputs.nixpkgs.lib.strings) hasSuffix;
          isLinux = system: hasSuffix "-linux" system;
          isDarwin = system: hasSuffix "-darwin" system;
        in
          if isLinux system
          then "ubuntu-24.04"
          else if isDarwin system
          then "macos-14"
          else throw "Unsupported system (platform): ${system}";
        nixosConfigs = let
          inherit (inputs.nixpkgs.lib.attrsets) filterAttrs mapAttrsToList;
        in {
          include = let
            pred = n: v: let
              inherit (v.pkgs) system;
              isWorkMachine = v: let
                inherit (builtins) elem hasAttr;
              in
                if hasAttr "nixfigs.meta" v.config
                then elem "work" v.config.nixfigs.meta.rolesEnabled
                else false;
            in
              !isWorkMachine v && n != "DZR-BUSY-LIGHT";
          in
            mapAttrsToList (n: v: {
              hostName = n;
              platform = systemToPlatform v.pkgs.stdenv.hostPlatform.system;
              inherit (v.pkgs) system;
            }) (filterAttrs pred self.nixosConfigurations);
        };
      in
        nixosConfigs;

      builds = let
        inherit (inputs.nixpkgs.lib) hasAttrByPath filterAttrs;
      in {
        sdImages = with builtins;
          mapAttrs (_: v: v.config.system.build.sdImage)
          (filterAttrs (_: v:
            hasAttrByPath ["config" "system" "build" "sdImage"] v)
          self.nixosConfigurations);
        isoImages = with builtins;
          mapAttrs (_: v: v.config.system.build.isoImage)
          (filterAttrs (_: v:
            hasAttrByPath ["config" "system" "build" "isoImage"] v)
          self.nixosConfigurations);
      };
>>>>>>> 9aa18130 (fix: Fix `pkgs.system` usages)
    };
    wemod-launcher = {
      url = "github:DeckCheatz/wemod-launcher?ref=refactor-shymega";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware drivers
    xrlinuxdriver = {
      url = "github:shymega/XRLinuxDriver?ref=shymega/nix-flake-support";
      inputs.nixpkgs.follows = "nixpkgs";
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
