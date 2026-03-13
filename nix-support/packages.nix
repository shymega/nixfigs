# SPDX-FileCopyrightText: 2024-2026 Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
# Expose packages from overlay enabled.d directories and shypkgs-public
{inputs, ...}: let
  inherit (inputs) self shypkgs-public;
  inherit (inputs.nixpkgs) lib;
  systemsModule = import ./systems.nix {inherit inputs;};

  readPackageNames = dir:
    map (f: lib.removeSuffix ".nix" f) (builtins.attrNames (builtins.readDir dir));

  stablePackages = readPackageNames ../overlays/stable/enabled.d;
  unstablePackages = readPackageNames ../overlays/unstable/enabled.d;

  mkPackages = system: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config = self.nixpkgs-config;
      overlays = [self.overlays.default];
    };
    stablePkgs = lib.genAttrs stablePackages (name: pkgs.${name});
    unstablePkgs = lib.genAttrs unstablePackages (name: pkgs.unstable.${name});
  in
    stablePkgs // unstablePkgs // shypkgs-public.packages.${system};
in
  systemsModule.forDefaultSystems mkPackages
