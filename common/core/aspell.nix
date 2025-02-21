# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, ... }:
let
  inherit (pkgs.stdenvNoCC) isLinux;
in
{
  environment.systemPackages = with pkgs; [
    aspellDicts.en
    aspellDicts.en-computers
  ];

  # Configure aspell system wide
  lib.mkIf = isLinux {
    environment.etc."aspell.conf".text = ''
      master en_US
      add-extra-dicts en-computers.rws
    '';
  };
}
