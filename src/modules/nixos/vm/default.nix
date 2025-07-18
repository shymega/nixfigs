# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
let
  inherit (config.nixfigs.roles) checkRoles;
  isVM = checkRoles ["virtual-machine"] config;
in {
  imports = lib.optionals isVM [
    ./libvirt.nix
    ./graphics.nix
    ./networking.nix
    ./rustdesk.nix
  ];
}