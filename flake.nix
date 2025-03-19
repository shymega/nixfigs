# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  description = "Dom's Nixified Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixfigs-virtual-private.url = "github:shymega/nixfigs-virtual-private-dummy";
    nixfigs-virtual.url = "github:shymega/nixfigs-virtual";
    nixfigs-work.url = "github:shymega/nixfigs-work-dummy";
    nixfigs-private.url = "github:shymega/nixfigs-private-dummy";
    devenv.url = "github:cachix/devenv/latest";
    hardware.url = "github:NixOS/nixos-hardware";
    hardware-shymega.url = "github:shymega/nixos-hardware?ref=shymega";
    impermanence.url = "github:nix-community/impermanence";
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
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib?ref=v3.0.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-shymega.url = "github:shymega/nixpkgs?ref=shymega/staging";
    nixos-flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote?ref=v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix?ref=release-24.11";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shymega-flake-registry = {
      url = "github:shymega/shymega-flake-registry";
      flake = false;
    };
    base16-schemes.url = "github:SenchoPens/base16.nix";
    nix-doom-emacs-unstraightened.url = "github:marienz/nix-doom-emacs-unstraightened";
    nixfigs-doom-emacs-personal = {
      url = "github:shymega/nixfigs-doom-emacs";
      flake = false;
    };
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    flake-utils.url = "github:numtide/flake-utils";
    shypkgs-private.url = "github:shymega/shypkgs-private-dummy";
    shypkgs-public.url = "github:shymega/shypkgs-public";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";
    nur-xddxdd = {
      url = "github:xddxdd/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ucodenix.url = "github:e-tho/ucodenix";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

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
        inherit (channels.nixpkgs) system;
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
        (inputs.nixpkgs.lib.optional enableLix
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
      inherit (inputs) self;
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
              !isWorkMachine v;
          in
            mapAttrsToList (n: v: {
              hostName = n;
              platform = systemToPlatform v.pkgs.system;
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
    };
}
