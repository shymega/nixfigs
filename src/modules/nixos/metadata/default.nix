# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  hostRoles ? [],
  metadata ? {},
  ...
}:
with lib; {
  options.nixfigs.meta = {
    rolesEnabled = mkOption {
      default = hostRoles;
      type = with types; listOf str;
    };
    hostAddress = mkOption {
      default = metadata;
      nullable = true;
      type = with types; str;
    };
  };
}
