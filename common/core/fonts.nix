# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    corefonts
    ibm-plex
    jetbrains-mono
    jetbrains-mono
    source-code-pro
  ];

  fonts.fontDir.enable = true;
}
