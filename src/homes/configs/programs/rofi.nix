# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  pkgs,
  ...
}:
lib.mkIf true {
  programs.rofi = {
    enable = true;
    font = "IBM Plex Mono";
    extraConfig = {
      dpi = 0;
    };
    plugins = with pkgs; [rofi-emoji];
    cycle = true;
    pass.enable = true;
  };
}
