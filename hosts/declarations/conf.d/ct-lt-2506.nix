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
  hostname = "ct-lt-2506-nixos";
  hostPlatform = "x86_64-linux";
  hostRoles = [
    "workstation"
    "work"
  ]; # Work-only system
  hardwareModules = with inputs; [
    hardware.nixosModules.common-cpu-intel # Adjust based on actual hardware
    hardware.nixosModules.common-pc-laptop
    hardware.nixosModules.common-pc-ssd
    hardware.nixosModules.common-pc
  ];
  extraModules = with inputs; [
    # TPM and secure boot for corporate compliance
    lanzaboote.nixosModules.lanzaboote
    {environment.systemPackages = [inputs.nixpkgs.legacyPackages.${hostPlatform}.sbctl];}
  ];
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderWorkLaptopSSHKey"; # Replace with actual key
  embedHm = true;
  remoteBuild = false; # Disable remote build for work systems
  deployable = true;
}
