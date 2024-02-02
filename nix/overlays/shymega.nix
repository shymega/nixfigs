# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, lib, ... }:
final: prev:
let
  importShymegaOverlay = overlay:
    lib.composeExtensions
      (_: _: { __inputs = inputs; })
      (import (./shymega + "/${overlay}"));

  shymegaOverlays =
    lib.mapAttrs'
      (overlay: _: lib.nameValuePair
        (lib.removeSuffix ".nix" overlay)
        (importShymegaOverlay overlay))
      (builtins.readDir ./shymega);
in
{
  shymega = import inputs.nixpkgs-shymega {
    inherit (prev) system;
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
    overlays = lib.attrValues shymegaOverlays;
  };
}
