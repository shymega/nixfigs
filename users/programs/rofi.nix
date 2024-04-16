# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, lib, pkgs, ... }:
let
  inherit (self.libx) isLinux;
in
lib.mkIf isLinux {

  programs.rofi = {
    enable = true;
    font = "IBM Plex Mono";
    extraConfig = { dpi = 0; };
    plugins = with pkgs; [ rofi-emoji ];
    cycle = true;
    pass.enable = true;
  };
}
