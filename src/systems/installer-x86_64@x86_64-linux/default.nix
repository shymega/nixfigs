# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
_: {
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
  system.stateVersion = "26.05";

  nixfigs.installer.isoImage.enable = true;
  nixfigs.installer.sdImage.enable = true;
}
