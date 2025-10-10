# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
# Hydra job definitions
{
  self,
  inputs,
  ...
}: let
  inherit
    (inputs.nixpkgs.lib)
    isDerivation
    filterAttrs
    mapAttrs
    elem
    ;
in {
  hydraJobs = let
    filterValidPkgs = let
      hasPlatform = sys: pkg: elem sys (pkg.meta.platforms or [sys]);
      isDistributable = pkg: (pkg.meta.license or {redistributable = true;}).redistributable;
      notBroken = pkg: !(pkg.meta.broken or false);
    in
      sys: pkgs:
        filterAttrs (
          _: pkg: isDerivation pkg && hasPlatform sys pkg && notBroken pkg && isDistributable pkg
        )
        pkgs;
    getConfigTopLevel = _: cfg: cfg.config.system.build.toplevel;
    getActivationPackage = _: cfg: cfg.config.home.activationPackage;
  in {
    pkgs = mapAttrs filterValidPkgs self.packages;
    hosts = mapAttrs getConfigTopLevel self.nixosConfigurations;
    users = mapAttrs getActivationPackage self.homeConfigurations;
    inherit (self.builds) sdImages isoImages;
  };
}
