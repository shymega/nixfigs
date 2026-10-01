# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
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
