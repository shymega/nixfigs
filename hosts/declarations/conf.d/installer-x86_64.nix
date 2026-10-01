# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{mkHost, ...}:
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
