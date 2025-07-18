# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  config,
  pkgs,
  ...
}:
{
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
  system.stateVersion = "25.05";

  nixfigs.installer.isoImage.enable = true;
  nixfigs.installer.sdImage.enable = true;
}
