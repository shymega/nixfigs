# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.writeScriptBin "net-type" ''
      #! ${pkgs.stdenv.shell}
      set -eu

      exec ${pkgs.lib.getExe' pkgs.networkmanager "nmcli"} \
        networking connectivity
    '')
  ];
}
