# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
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
