# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/nixos/iso
  ];

  nixfigs.installer = {
    enable = true;
    imageName = "nixos-installer-x86_64";
    includeZeroTier = true;
    includeZFS = true;
    sshKeys = [
      # Add your SSH public keys here
      # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"
    ];
    extraPackages = with pkgs; [
      # Additional packages for x86_64 installer (these are now included automatically)
    ];
  };

  # Architecture-specific optimizations
  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "console=tty0"
  ];

  # Enable hardware support
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Network interface naming
  networking.usePredictableInterfaceNames = true;

  # System information
  system.stateVersion = "24.05";
}