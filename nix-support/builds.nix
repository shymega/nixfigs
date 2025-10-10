# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
# Build definitions for SD images and ISO images
{
  self,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs.lib) hasAttrByPath filterAttrs;
in {
  builds = {
    sdImages = with builtins;
      mapAttrs (_: v: v.config.system.build.sdImage) (
        filterAttrs (_: v: hasAttrByPath ["config" "system" "build" "sdImage"] v) self.nixosConfigurations
      );
    isoImages = with builtins;
      mapAttrs (_: v: v.config.system.build.isoImage) (
        filterAttrs (
          _: v: hasAttrByPath ["config" "system" "build" "isoImage"] v
        )
        self.nixosConfigurations
      );
  };
}
