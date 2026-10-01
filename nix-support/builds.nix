# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
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
