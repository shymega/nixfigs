# SPDX-FileCopyrightText: 2024-2026 Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{lib, ...}: {
  hardware.enableAllFirmware = lib.mkDefault true;
}
