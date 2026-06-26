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
  importStableOverlay = overlay:
    composeExtensions (_: _: {__inputs = inputs;}) (import (./stable/enabled.d + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable/enabled.d;

  stableOverlaysWithImports =
    mapAttrs' (
      overlay: _: nameValuePair (removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = with inputs; let
    openclawOverlaySafe = final: prev:
    # Only apply when stdenv exists (real nixpkgs, not flake check)
      if prev ? stdenv
      then inputs.nix-openclaw.overlays.default final prev
      else {};
    hyprnixOverlaySafe = _: prev: let
      system = prev.stdenv.hostPlatform.system;
    in
      hyprnix.packages.${system} or {};
  in [
    devenv.overlays.default
    dzr-taskwarrior-recur.overlays.default
    hyprnixOverlaySafe
    nix-alien.overlays.default
    nix-cachyos-kernel.overlays.pinned
    nix-doom-emacs-unstraightened.overlays.default
    nur.overlays.default
    openclawOverlaySafe
    shypkgs-public.overlays.default
    sops-nix.overlays.default
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
