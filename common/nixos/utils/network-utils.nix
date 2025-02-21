# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.writeScriptBin "net-type" ''
      #! ${pkgs.stdenv.shell}
      set -eu

      exec ${pkgs.networkmanager.outPath}/bin/nmcli \
        networking connectivity
    '')
  ];
}
