# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, inputs, outputs, pkgs, ... }: {
  fonts.packages = with pkgs; [
    open-dyslexic
    fira
    fira-code
    jetbrains-mono
    font-awesome_5
    font-awesome_4
    noto-fonts
    noto-fonts-emoji
    emojione
    twemoji-color-font
    ibm-plex
    source-code-pro
    jetbrains-mono
    font-awesome
    corefonts
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  fonts.fontDir.enable = true;
}
