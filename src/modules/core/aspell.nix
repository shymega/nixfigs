# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  pkgs,
  lib,
  ...
}:
with lib; {
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
