# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  inputs,
  lib,
  ...
}:
with lib;
  _: prev: let
    importShymegaOverlay = overlay: composeExtensions (_: _: {__inputs = inputs;}) (import (./enabled.d + "/${overlay}"));

    shymegaOverlays = mapAttrs' (
      overlay: _: nameValuePair (removeSuffix ".nix" overlay) (importShymegaOverlay overlay)
    ) (builtins.readDir ./enabled.d);
  in {
    shymega = import inputs.nixpkgs-shymega {
      inherit (prev) system;
      config = inputs.self.nixpkgs-config;
      overlays = builtins.attrValues shymegaOverlays;
    };
  }
