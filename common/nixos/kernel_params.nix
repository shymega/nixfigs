# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
{
  boot.kernelParams = lib.mkAfter [
    "loglevel=3"
    "quiet"
    "rd.udev.log_level=3"
    "splash"
    "systemd.show_status=auto"
    "systemd.unified_cgroup_hierarchy=1"
  ];
}
