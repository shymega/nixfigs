# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, lib, ... }:
final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    inherit (prev) system;
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
    overlays =
      let
        importUnstableOverlay = overlay:
          lib.composeExtensions
            (_: _: { __inputs = inputs; })
            (import (./unstable + "/${overlay}"));

        unstableOverlays =
          lib.mapAttrs'
            (overlay: _: lib.nameValuePair
              (lib.removeSuffix ".nix" overlay)
              (importUnstableOverlay overlay))
            (builtins.readDir ./unstable);
      in
      lib.attrValues unstableOverlays;
  };
}
