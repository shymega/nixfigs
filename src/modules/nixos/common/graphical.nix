# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{ ... }:
{
  imports = [
    ./wayland.nix
    ./x11.nix
  ];
}
