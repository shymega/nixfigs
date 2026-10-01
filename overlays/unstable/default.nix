# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  inputs,
  lib,
  ...
}: final: _prev: let
  importUnstableOverlay = overlay: lib.composeExtensions (_: _: {__inputs = inputs;}) (import (./enabled.d + "/${overlay}"));

  unstableOverlays = lib.mapAttrs' (
    overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importUnstableOverlay overlay)
  ) (builtins.readDir ./enabled.d);
in {
  unstable = import inputs.nixpkgs-unstable {
    localSystem = final.stdenv.hostPlatform.system;
    config = inputs.self.nixpkgs-config;
    overlays = builtins.attrValues unstableOverlays;
  };
}
