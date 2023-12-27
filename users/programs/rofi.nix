# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, config, lib, pkgs, ... }:
lib.mkIf self.isNixOS || self.isForeignNix {

  programs.rofi = {
    enable = true;
    font = "IBM Plex Mono";
    extraConfig = { dpi = 0; };
    plugins = with pkgs; [ rofi-emoji ];
    cycle = true;
    pass.enable = true;
  };
}
