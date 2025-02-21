# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ pkgs, lib, ... }:
let
  inherit (lib.my) isNixOS;
in
with lib;
{
  environment.systemPackages = with pkgs; [
    aspellDicts.en
    aspellDicts.en-computers
  ];

  # Configure aspell system wide
  environment.etc."aspell.conf".text = optionalString isNixOS ''
    master en_US
    add-extra-dicts en-computers.rws
  '';
}
