# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  lib,
  config,
  ...
}:
with lib; let
  enabled = checkRoles ["gaming"] config;
in {
  config = mkIf enabled {
    hardware.steam-hardware.enable = true;
  };
}
