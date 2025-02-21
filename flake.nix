# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  description = "Main entrypoint to my NixOS flakes";

  nixConfig = {
    extra-trusted-substituters = [
      "https://attic.mildlyfunctional.gay/nixbsd"
      "https://cache.dataaturservice.se/spectrum/"
      "https://cache.nixos.org/"
      "https://deploy-rs.cachix.org/"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://nix-on-droid.cachix.org"
      "https://numtide.cachix.org"
      "https://pre-commit-hooks.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "deploy-rs.cachix.org-1:xfNobmiwF/vzvK1gpfediPwpdIP0rpDV2rYqx40zdSI="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
      "nixbsd:gwcQlsUONBLrrGCOdEboIAeFq9eLaDqfhfXmHZs1mgc="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
    ];
  };

  outputs = inputs: let
    inherit (inputs) self;
    genPkgs = system:
      import inputs.nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
        config = self.nixpkgs-config;
      };

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    treeFmtEachSystem = f: inputs.nixpkgs.lib.genAttrs systems (system: f inputs.nixpkgs.legacyPackages.${system});
    treeFmtEval = treeFmtEachSystem (
      pkgs:
        inputs.nixfigs-helpers.inputs.treefmt-nix.lib.evalModule pkgs inputs.nixfigs-helpers.helpers.formatter
    );

    forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
  in {
    hosts = inputs.nixfigs-public.hosts // inputs.nixfigs-private.hosts;
    secrets = inputs.nixfigs-secrets.system // inputs.nixfigs-secrets.user;
    deploy = import ./nix/deploy.nix {
      inherit self inputs;
      inherit (inputs.nixpkgs) lib;
    };
    inherit (inputs.nixfigs-pkgs) overlays packages nixpkgs-config;
    # for `nix fmt`
    formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.system}.config.build.wrapper);
    # for `nix flake check`
    checks =
      treeFmtEachSystem (pkgs: {
        formatting = treeFmtEval.${pkgs}.config.build.wrapper;
      })
      // forEachSystem (system: {
        pre-commit-check = import "${inputs.nixfigs-helpers.helpers.checks}" {
          inherit self system;
          inherit (inputs.nixfigs-helpers) inputs;
          inherit (inputs.nixpkgs) lib;
        };
      });
    devShells = forEachSystem (
      system: let
        pkgs = genPkgs system;
      in
        import inputs.nixfigs-helpers.helpers.devShells {inherit pkgs self system;}
    );
    builds = let
      forSystem = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aaarch64-darwin"
      ];
    in
      forSystem (
        system: let
          pkgs = genPkgs system;
        in {
          sdImages = {
            SMITH-LINUX = self.nixosConfigurations.SMITH-LINUX.config.system.build.sdImage;
            GRDN-BED-UNIT = self.nixosConfigurations.GRDN-BED-UNIT.config.system.build.sdImage;
            DZR-OFFICE-BUSY-LIGHT-UNIT =
              self.nixosConfigurations.DZR-OFFICE-BUSY-LIGHT-UNIT.config.system.build.sdImage;
            DZR-PETS-CAM-UNIT = self.nixosConfigurations.DZR-PETS-CAM-UNIT.config.system.build.sdImage;
            CLOCKWORK-DT-CM4 = self.nixosConfigurations.CLOCKWORK-DT-CM4.config.system.build.sdImage;
            CLOCKWORK-UC-CM4 = self.nixosConfigurations.CLOCKWORK-UC-CM4.config.system.build.sdImage;
          };
          sdImages-collections = let
            images = self.builds.${system}.sdImages;
          in
            with images; {
              all = with builtins;
                map (k: getAttr k self.builds.${system}.sdImages) (attrNames self.builds.${system}.sdImages);
              clockworkpi = CLOCKWORK-UC-CM4 // CLOCKWORK-DT-CM4;
              pi-automation = DZR-OFFICE-BUSY-LIGHT-UNIT // DZR-PETS-CAM-UNIT // GRDN-BED-UNIT;
              pi-desktops = SMITH-LINUX;
            };
          isos = {
            all = {};
          };
          isos-collections = let
            inherit (self.builds.${system}) isos;
          in
            with isos; {
              all = with builtins;
                map (k: getAttr k self.builds.${system}.isos) (attrNames self.builds.${system}.isos);
            };

          all = pkgs.symlinkJoin {
            name = "all";
            paths = let
              generatorsAll = inputs.nixfigs-private.generators // inputs.nixfigs-public.generators;
            in
              with builtins;
                (map (k: getAttr k self.builds.${system}.sdImages) (attrNames self.builds.${system}.sdImages))
                ++ (map (k: getAttr k generatorsAll) (attrNames generatorsAll))
                ++ (map (k: getAttr k self.builds.${system}.isos.all) (attrNames self.builds.${system}.isos.all));
          };
        }
      );
    common = inputs.nixfigs-common.common // inputs.nixfigs-private.common;
    inherit (inputs.nixfigs-helpers) helpers;
    homeConfigurations =
      inputs.nixfigs-homes.homeConfigurations // inputs.nixfigs-private.homeConfigurations;
    homeModules =
      inputs.nixfigs-homes.homeModules // inputs.nixfigs-private.homeModules;
    inherit (inputs.nixfigs-networks) networks;
    nixosConfigurations =
      inputs.nixfigs-private.nixosConfigurations // inputs.nixfigs-public.nixosConfigurations;
    nixosModules = inputs.nixfigs-private.nixosModules // inputs.nixfigs-public.nixosModules;
    inherit (inputs.nixfigs-roles) roles checkRole checkRoles;
    inherit (inputs.nixfigs-devenvs) templates; # FIXME: Add `legacyShells` output.
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-shymega.url = "github:shymega/nixpkgs?ref=shymega/staging";
    nixfigs-helpers.url = "github:shymega/nixfigs-helpers";
    nixfigs-pkgs.url = "github:shymega/nixfigs-pkgs";
    nixfigs-private.url = "github:shymega/nixfigs-private";
    nixfigs-public.url = "github:shymega/nixfigs-public";
    nixfigs-homes.url = "github:shymega/nixfigs-homes";
    nixfigs-secrets.url = "github:shymega/nixfigs-secrets";
    nixfigs-roles.url = "github:shymega/nixfigs-roles";
    nixfigs-devenvs.url = "github:shymega/nixfigs-devenvs";
    hardware.url = "github:NixOS/nixos-hardware";
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
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    shypkgs-private.url = "github:shymega/shypkgs-private";
    shypkgs-public.url = "github:shymega/shypkgs-public";
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
