# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  inputs,
  lib,
  ...
}:
with lib;
_: prev:
let
  importUnstableOverlay =
    overlay: composeExtensions (_: _: { __inputs = inputs; }) (import (./enabled.d + "/${overlay}"));

  unstableOverlays = mapAttrs' (
    overlay: _: nameValuePair (removeSuffix ".nix" overlay) (importUnstableOverlay overlay)
  ) (builtins.readDir ./enabled.d);
in
{
  unstable = import inputs.nixpkgs-unstable {
    inherit (prev) system;
    config = inputs.self.nixpkgs-config;
    overlays = builtins.attrValues unstableOverlays;
  };
}
