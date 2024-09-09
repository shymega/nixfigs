# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, config, lib, ... }:
{
  imports = [
    inputs.diskos.nixosModules.default
    ./disko.nix
    ./disks.nix
    inputs.jovian-nixos.nixosModules.default
  ];

  jovian.devices.steamdeck.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
