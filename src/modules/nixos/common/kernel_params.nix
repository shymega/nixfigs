# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{lib, ...}: {
  boot.kernelParams = lib.mkBefore [
    "boot.shell_on_fail"
    "loglevel=3"
    "quiet"
    "systemd.show_status=false"
    "udev.log_level=3"
    "udev.log_priority=3"
    "splash"
  ];
  boot.kernel.sysctl."kernel.sysrq" = 1;
}
