# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  mkHost,
  inputs,
  ...
}:
mkHost {
  type = "nixos";
  hostname = "installer-x86_64";
  hostPlatform = "x86_64-linux";
  hostRoles = [
    "installer"
    "personal"
  ];

  pubkey = null;
  embedHm = false;
  remoteBuild = false;
  deployable = false;
}
