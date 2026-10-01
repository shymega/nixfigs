# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
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
