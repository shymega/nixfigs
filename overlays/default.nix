# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  lib,
  inputs,
  ...
}: let
  importStableOverlay = overlay: lib.composeExtensions (_: _: {__inputs = inputs;}) (import (./stable/enabled.d + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable/enabled.d;

  stableOverlaysWithImports =
    lib.mapAttrs' (
      overlay: _: lib.nameValuePair (lib.removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = with inputs; [
    agenix.overlays.default
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
    default = lib.composeManyExtensions (
      defaultOverlays ++ customOverlays ++ (lib.attrValues stableOverlaysWithImports)
    );
  }
