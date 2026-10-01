# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{lib, ...}:
with lib; {
  options.nixfigs.graphical.windowManagers = {
    selectedWindowManager = lib.mkOption {
      type = lib.types.str;
      default = "hyprland";
    };
  };
}
