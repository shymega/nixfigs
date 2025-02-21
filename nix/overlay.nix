# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ lib, inputs, ... }:

let
  importStableOverlay = overlay:
    lib.composeExtensions
      (_: _: { __inputs = inputs; })
      (import (./overlays/stable + "/${overlay}"));

  stableOverlays = builtins.readDir ./overlays/stable;

  stableOverlaysWithImports = lib.mapAttrs'
    (overlay: _: lib.nameValuePair
      (lib.removeSuffix ".nix" overlay)
      (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = [
    inputs.agenix.overlays.default
    inputs.android-nixpkgs.overlays.default
    inputs.cosmo-codios-codid.overlays.default
    inputs.deploy-rs.overlays.default
    inputs.nix-alien.overlays.default
    inputs.nur.overlay
    inputs.shycode.overlays.default
    inputs.shymacs.overlays.default
    inputs.emacsconf2nix.overlays.default
  ];

  customOverlays = [
    (import ./overlays/master.nix { inherit inputs lib; })
    (import ./overlays/shymega.nix { inherit inputs lib; })
    (import ./overlays/unstable.nix { inherit inputs lib; })
    (import ./overlays/asfp.nix { inherit inputs; })
  ];

in
stableOverlaysWithImports // {
  default = lib.composeManyExtensions (defaultOverlays ++ customOverlays ++ (lib.attrValues stableOverlaysWithImports));
}
