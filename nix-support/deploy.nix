# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  self,
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}:
let
  inherit (inputs) deploy-rs;

  deploySystem =
    system:
    let
      inherit (lib) hasSuffix;
    in
    if hasSuffix system "-darwin" then
      "darwin"
    else if hasSuffix system "-linux" then
      "nixos"
    else
      throw "Unsupported system: ${system}";

  genNode =
    hostname: cfg:
    let
      inherit (self.hosts.${hostname})
        address
        hostPlatform
        remoteBuild
        username
        ;
      inherit (deploy-rs.lib.${hostPlatform}) activate;
    in
    {
      inherit remoteBuild;
      hostname = address;
      sshUser = username;
      profiles.system.path = activate.${deploySystem hostPlatform} cfg;
    };
in
{
  autoRollback = false;
  magicRollback = true;
  user = "root";
  nodes = lib.mapAttrs genNode (
    lib.filterAttrs (_: cfg: cfg._module.specialArgs.deployable) (
      self.nixosConfigurations // self.darwinConfigurations
    )
  );
}
