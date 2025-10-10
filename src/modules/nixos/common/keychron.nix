# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  enabled = checkRoles ["personal" "work" "workstation"] config;
in {
  config = mkIf enabled {
    boot.extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';
    environment.systemPackages = with pkgs; [
      via
    ];
    services.udev.packages = [pkgs.via];
    hardware.keyboard.qmk.enable = true;
  };
}
