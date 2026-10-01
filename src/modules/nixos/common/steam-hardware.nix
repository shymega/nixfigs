# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
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
