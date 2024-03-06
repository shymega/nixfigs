# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, lib, ... }:
_final: prev:
let
  importMasterOverlay = overlay:
    lib.composeExtensions
      (_: _: { __inputs = inputs; })
      (import (./master + "/${overlay}"));

  masterOverlays =
    lib.mapAttrs'
      (overlay: _: lib.nameValuePair
        (lib.removeSuffix ".nix" overlay)
        (importMasterOverlay overlay))
      (builtins.readDir ./master);
in
{
  master = import inputs.nixpkgs-master {
    inherit (prev) system;
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
    overlays = lib.attrValues masterOverlays;
  };
}
