# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  mkHost,
  genPkgs,
  self,
  inputs,
  ...
}:
mkHost rec {
  type = "nixos";
  hostname = "DZR-BUSY-LIGHT";
  hostPlatform = "armv6l-linux";
  hostRoles = ["minimal"];
  baseModules = [];
  hardwareModules = with inputs; [
    hardware.nixosModules.common-pc
  ];
  extraModules = [
  ];
  pubkey = "";
  embedHm = false;
  remoteBuild = false;
  deployable = true;
  enableFoundationModules = false;
}
