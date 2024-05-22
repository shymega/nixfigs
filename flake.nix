# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
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

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

    imports = [ ./modules/parts ./overlays ./secrets ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-shymega.url = "github:shymega/nixpkgs/master";
    shymacs.url = "github:shymega/shymacs";
    shycode.url = "github:shymega/shycode";
    emacsconf2nix.url = "github:shymega/emacsconf2nix";
    nixfigs-priv.url = "github:shymega/nixfigs-priv/main";
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    agenix.url = "github:ryantm/agenix";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-alien.url = "github:thiagokokada/nix-alien";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-darwin.url = "github:LnL7/nix-darwin";
    deploy-rs.url = "github:serokell/deploy-rs";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    nix-on-droid.url = "github:nix-community/nix-on-droid/release-23.11";
    stylix.url = "github:danth/stylix";
    srvos.url = "github:nix-community/srvos";
    android-nixpkgs.url = "github:tadfisher/android-nixpkgs/stable";
    asfp.url = "github:robbins/nixpkgs/android-studio-for-platform";
  };
}
