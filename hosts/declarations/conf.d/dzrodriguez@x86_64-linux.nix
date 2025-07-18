# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  mkHost,
  genPkgs,
  self,
  inputs,
  ...
}:
mkHost rec {
  type = "home-manager";
  hostPlatform = "x86_64-linux";
  hostRoles = [
    "workstation"
    "gaming"
    "personal"
    "home-pc"
  ];
  username = "dzrodriguez";
}
