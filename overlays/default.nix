# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ lib, inputs, ... }:

let
  importStableOverlay =
    overlay: lib.composeExtensions (_: _: { __inputs = inputs; }) (import (./stable + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable;

  stableOverlaysWithImports = lib.mapAttrs'
    (
      overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = [
    inputs.agenix.overlays.default
    inputs.aimu.overlays.default
    inputs.android-nixpkgs.overlays.default
    inputs.bestool.overlays.default
    inputs.deckcheatz.overlays.default
    inputs.dzr-taskwarrior-recur.overlays.default
    inputs.emacsconf2nix.overlays.default
    inputs.nix-alien.overlays.default
    inputs.nur.overlay
    inputs.wemod-launcher.overlays.default
  ];

  customOverlays = [
    #    (import ./master.nix { inherit inputs lib; })
    #    (import ./shymega.nix { inherit inputs lib; })
    (import ./unstable.nix { inherit inputs lib; })
  ];
in
stableOverlaysWithImports
  // {
  default = lib.composeManyExtensions (
    defaultOverlays ++ customOverlays ++ (lib.attrValues stableOverlaysWithImports)
  );
}
