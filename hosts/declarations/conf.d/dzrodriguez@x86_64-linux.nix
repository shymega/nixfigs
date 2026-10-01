# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{mkHost, ...}:
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
