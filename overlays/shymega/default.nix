# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{inputs, ...}: final: _prev: {
  shymega = import inputs.nixpkgs-shymega {
    localSystem = final.stdenv.hostPlatform.system;
    config = inputs.self.nixpkgs-config;
    # overlays = builtins.attrValues shymegaOverlays;
  };
}
