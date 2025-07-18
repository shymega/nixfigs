# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  description = "Dom's Nixified Flake";

  outputs = inputs: let
    inherit (inputs) self;
    rolesModule = import ./nix-support/roles.nix;
    treeFmtEachSystem = let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
      f: inputs.nixpkgs.lib.genAttrs allSystems (system: f inputs.nixpkgs.legacyPackages.${system});
    treeFmtEval = treeFmtEachSystem (
      pkgs:
        inputs.treefmt-nix.lib.evalModule pkgs ./nix-support/formatter.nix
    );
  in {
    inherit (rolesModule) roles;
    inherit (rolesModule) utils;
    nixpkgs-config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
      allowBroken = false;
      allowInsecurePredicate = _: true;
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
        listToAttrs (map (v: {
            name = v.hostname or "home-manager-cfg";
            value = v;
          })
          list);
      raw = import ./hosts {inherit self inputs;};
    in
      lak (map (v:
        import v {
          inherit self inputs;
          inherit (raw) genPkgs mkHost;
        })
      raw.enabled);
    packages = let
      inherit (inputs.shypkgs-public) forAllSystems;
    in
      forAllSystems (system:
        inputs.shypkgs-public.packages.${system}
        // {
          totp = inputs.nixpkgs.legacyPackages.${system}.callPackage ./packages/totp {};
        });

    hydraJobs = let
      inherit (inputs.nixpkgs.lib) isDerivation filterAttrs mapAttrs elem;
      filterValidPkgs = let
        hasPlatform = sys: pkg: elem sys (pkg.meta.platforms or [sys]);
        isDistributable = pkg: (pkg.meta.license or {redistributable = true;}).redistributable;
        notBroken = pkg: !(pkg.meta.broken or false);
      in
        sys: pkgs:
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

    formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);

    devShells = let
      allSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = f: inputs.nixpkgs.lib.genAttrs allSystems f;
    in
      forEachSystem (system: {
        default = import ./nix-support/devshell.nix {
          inherit inputs self system;
        };
      });

    checks = let
      allSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = f: inputs.nixpkgs.lib.genAttrs allSystems f;
    in
      builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy)
      inputs.deploy-rs.lib
      // treeFmtEachSystem (pkgs: {
        formatting = treeFmtEval.${pkgs}.config.build.wrapper;
      })
      // forEachSystem (
        system: {
          pre-commit-check = import ./nix-support/checks.nix {
            inherit inputs system self;
          };
        }
      );

    githubActions.matrix = let
      systemToPlatform = system: let
        inherit (inputs.nixpkgs.lib.strings) hasSuffix;
        isDarwin = system: hasSuffix "-darwin" system;
      in
        if system == "aarch64-linux"
        then "ubuntu-24.04-arm"
        else if hasSuffix "-linux" system
        then "ubuntu-24.04"
        else if isDarwin system
        then "macos-14"
        else throw "Unsupported system (platform): ${system}";
      nixosConfigs = let
        inherit (inputs.nixpkgs.lib.attrsets) filterAttrs mapAttrsToList;
      in {
        include = with builtins; let
          pred = n: v: let
            isWorkMachine = v:
              if hasAttr "nixfigs.meta.rolesEnabled" v.config
              then elem "work" v.config.nixfigs.meta.rolesEnabled
              else false;
            notUnsupportedSystem = let
              unsupportedSystems = [
                "armv6l-linux"
                "armv7l-linux"
                "riscv64-linux"
              ];
            in
              sys: any (x: x == sys) unsupportedSystems;
          in
            !isWorkMachine v && !notUnsupportedSystem v.pkgs.system;
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

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixfigs-virtual-private.url = "github:shymega/nixfigs-virtual-private-dummy";
    nixfigs-work.url = "github:shymega/nixfigs-work-dummy";
    nixfigs-private.url = "github:shymega/nixfigs-private-dummy";
    nixfigs-secrets.url = "github:shymega/nixfigs-secrets";
    nixfigs-networks.url = "github:shymega/nixfigs-networks-dummy";
    devenv.url = "github:cachix/devenv?ref=latest";
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
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote?ref=v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix?ref=release-25.05";
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
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
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
    chaotic.url = "github:chaotic-cx/nyx?ref=nyxpkgs-unstable";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    hyprland.url = "github:hyprwm/Hyprland?rev=f08167c877227b2c9e0b59e7d38d072bdcd944a5";
    shyemacs-cfg = {
      url = "github:shymega/emacs-cfg";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nur.url = "github:nix-community/NUR";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs?ref=stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deckcheatz.url = "github:deckcheatz/deckcheatz";
    dzr-taskwarrior-recur.url = "github:shymega/dzr-taskwarrior-recur";
    wemod-launcher.url = "github:DeckCheatz/wemod-launcher?ref=refactor-shymega";
    xrlinuxdriver.url = "github:shymega/XRLinuxDriver?ref=shymega/nix-flake-support";
    nm2nix.url = "github:Janik-Haag/nm2nix";
  };
}

