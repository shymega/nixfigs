# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ lib, ... }: {
  imports = [ ./power-targets.nix ./network-targets.nix ./power-mangement.nix ];
}
