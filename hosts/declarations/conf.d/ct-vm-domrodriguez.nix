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
  hostname = "ct-vm-domrodriguez";
  hostPlatform = "x86_64-linux";
  hostRoles = [
    "virtual-machine"
    "personal"
    "workstation"
    "libvirt"
  ]; # VM-specific roles
  hardwareModules = with inputs; [
    hardware.nixosModules.common-cpu-amd # Assuming AMD host (DEUSEX-LINUX)
    hardware.nixosModules.common-pc
  ];
  extraModules = [
    # VM-specific modules will be imported in system config
  ];
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderVMSSHKey"; # Replace with actual VM key
  embedHm = true;
  remoteBuild = false; # VM doesn't need remote builds
  deployable = true; # Can be deployed via libvirt
}
