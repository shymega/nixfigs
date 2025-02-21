# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
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
