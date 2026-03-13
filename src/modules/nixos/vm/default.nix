# SPDX-FileCopyrightText: 2024-2026 Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  ...
}: let
  inherit (lib) checkRoles;
  isVM = checkRoles ["virtual-machine"] config;
in {
  imports = lib.optionals isVM [
    ./libvirt.nix
    ./graphics.nix
    ./networking.nix
    ./rustdesk.nix
  ];
}
