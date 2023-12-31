# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ lib, inputs, ... }:
let
  importStableOverlay = overlay:
    lib.composeExtensions
      (_: _: { __inputs = inputs; })
      (import (./overlays/stable + "/${overlay}"));

  stableOverlays =
    lib.mapAttrs'
      (overlay: _: lib.nameValuePair
        (lib.removeSuffix ".nix" overlay)
        (importStableOverlay overlay)
      )
      (builtins.readDir ./overlays/stable);
in
stableOverlays // {
  default = lib.composeManyExtensions ([
    inputs.agenix.overlays.default
    inputs.deploy-rs.overlay
    inputs.nur.overlay
    inputs.nix-alien.overlays.default
  ] ++ ([
    (import ./overlays/master.nix { inherit inputs lib; })
    (import ./overlays/shymega.nix { inherit inputs lib; })
    (import ./overlays/unstable.nix { inherit inputs lib; })
  ]) ++ (lib.attrValues stableOverlays));
}
