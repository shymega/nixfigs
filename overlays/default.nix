# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  lib,
  inputs,
  ...
}:
with lib; let
  importStableOverlay = overlay: composeExtensions (_: _: {__inputs = inputs;}) (import (./stable/enabled.d + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable/enabled.d;

  stableOverlaysWithImports =
    mapAttrs' (
      overlay: _: nameValuePair (removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = with inputs; [
    sops-nix.overlays.default
    android-nixpkgs.overlays.default
    deckcheatz.overlays.default
    dzr-taskwarrior-recur.overlays.default
    nix-alien.overlays.default
    nix-doom-emacs-unstraightened.overlays.default
    nur.overlays.default
    shypkgs-public.overlays.default
    xrlinuxdriver.overlays.default
  ];

  customOverlays = [
    (import ./shymega {inherit inputs lib;})
    (import ./unstable {inherit inputs lib;})
  ];
in
  stableOverlaysWithImports
  // {
    default = composeManyExtensions (
      defaultOverlays ++ customOverlays ++ (attrValues stableOverlaysWithImports)
    );
  }
