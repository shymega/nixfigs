# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  systemd.targets.ac = {
    conflicts = [ "battery.target" ];
    description = "On AC power";
    unitConfig = { DefaultDependencies = "false"; };
  };

  systemd.targets.battery = {
    conflicts = [ "ac.target" ];
    description = "On battery power";
    unitConfig = { DefaultDependencies = "false"; };
  };
}
