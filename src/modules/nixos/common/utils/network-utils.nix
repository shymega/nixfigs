# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeScriptBin "net-type" ''
      #! ${pkgs.stdenv.shell}
      set -eu

      exec ${pkgs.lib.getExe' pkgs.networkmanager "nmcli"} \
        networking connectivity
    '')
  ];
}
