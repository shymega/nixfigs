# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  lib,
  config,
  ...
}:
with lib; let
  enabled = checkRoles ["gaming" "steam-deck" "jovian"] config;
in {
  config = mkIf enabled {
    hardware.steam-hardware.enable = true;
  };
}
