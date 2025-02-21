# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ self
, inputs
, lib
, ...
}:
let
  inherit (inputs) deploy-rs;

  genNixosNode =
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
      profiles.system.path = activate.nixos cfg;
    };

  genDarwinNode =
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
      profiles.system.path = activate.darwin cfg;
    };
in
{
  autoRollback = false;
  magicRollback = true;
  user = "root";
  nodes = lib.mapAttrs genNixosNode
    (
      lib.filterAttrs (_: cfg: cfg._module.specialArgs.deployable) self.nixosConfigurations
    ) // lib.mapAttrs genDarwinNode (
    lib.filterAttrs (_: cfg: cfg._module.specialArgs.deployable) self.nixosConfigurations
  );
}
