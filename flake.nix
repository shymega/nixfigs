# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  description = "Main entrypoint to my NixOS flakes";

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
    formatter = treeFmtEachSystem (pkgs: treeFmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
    # for `nix flake check`
    checks =
      treeFmtEachSystem
      (pkgs: {
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
        isWorkHostname = n: let
          inherit (inputs.nixpkgs.lib.strings) hasInfix;
        in
          hasInfix "ct-" n;
        pred = _n: v: let
          inherit (v.pkgs) system;
          inherit (v.config.networking) hostName;
        in
          (system == "aarch64-linux" || system == "x86_64-linux") && !isWorkHostname hostName;
      in {
        include =
          mapAttrsToList
          (n: v: {
            hostName = n;
            platform = systemToPlatform v.pkgs.stdenv.hostPlatform.system;
          })
          (filterAttrs pred self.nixosConfigurations);
      };
    in
      nixosConfigs;
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.follows = "nixfigs-homes/home-manager";
    shypkgs-private.url = "github:shymega/shypkgs-private";
    shypkgs-public.url = "github:shymega/shypkgs-public";
  };
}
