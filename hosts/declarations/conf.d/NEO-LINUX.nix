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
  hostname = "NEO-LINUX";
  hostPlatform = "x86_64-linux";
  hostRoles = ["workstation" "gaming" "personal" "home-pc"];
  hardwareModules = with inputs; [
    hardware.nixosModules.common-cpu-amd
    hardware.nixosModules.common-gpu-amd
    hardware.nixosModules.common-pc-ssd
    hardware.nixosModules.common-pc
  ];
  extraModules = with inputs; [
    lanzaboote.nixosModules.lanzaboote
    {environment.systemPackages = [inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl];}
  ];
  pubkey = "";
  embedHm = true;
  remoteBuild = true;
  deployable = true;
}
