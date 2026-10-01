# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{
  mkHost,
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
