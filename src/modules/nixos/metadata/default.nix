# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  hostRoles ? [],
  hostAddress ? null,
  ...
}:
with lib; {
  options.nixfigs.meta = {
    rolesEnabled = mkOption {
      default = hostRoles;
      type = with types; listOf str;
      description = "List of roles enabled for this host";
    };
    hostAddress = mkOption {
      default = hostAddress;
      type = with types; nullOr str;
      description = "Host address for deployment";
    };
  };

  config.nixfigs.meta = {
    rolesEnabled = mkDefault hostRoles;
    hostAddress = mkDefault hostAddress;
  };
}
