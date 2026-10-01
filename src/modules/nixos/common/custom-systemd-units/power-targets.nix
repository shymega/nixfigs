# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  systemd.targets.ac = {
    conflicts = ["battery.target"];
    description = "On AC power";
    unitConfig = {
      DefaultDependencies = "false";
    };
  };

  systemd.targets.battery = {
    conflicts = ["ac.target"];
    description = "On battery power";
    unitConfig = {
      DefaultDependencies = "false";
    };
  };
}
