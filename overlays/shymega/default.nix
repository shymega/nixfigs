# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{inputs, ...}: final: _prev: {
  shymega = import inputs.nixpkgs-shymega {
    localSystem = final.stdenv.hostPlatform.system;
    config = inputs.self.nixpkgs-config;
    # overlays = builtins.attrValues shymegaOverlays;
  };
}
