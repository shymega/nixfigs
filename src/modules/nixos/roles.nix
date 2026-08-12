# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  hostRoles,
  ...
}:
with lib; {
  options.nixfigs.meta.rolesEnabled = mkOption {
    default = hostRoles;
    type = with types; listOf str;
  };
}
