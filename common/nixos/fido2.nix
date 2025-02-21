# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:
{
  security.pam.u2f = {
    enable = true;
    cue = true;
  };
  services.udev.packages = with pkgs; [
    solo2-cli
  ];
}
