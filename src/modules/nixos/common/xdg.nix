# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    config.common.default = "wlr;gtk";
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    wlr.enable = true;
  };
}
