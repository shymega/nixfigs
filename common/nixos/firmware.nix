# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ lib }: {
  hardware.enableAllFirmware = lib.mkDefault true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
