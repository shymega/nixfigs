# SPDX-FileCopyrightText: 2024-2026 Rodriguez <shymega@shymega.org.uk>
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
      default = builtins.hasAttr "hostAddress" metadata && builtins.getAttr "hostAddress" metadata;
      type = with types; str;
    };
  };
}
