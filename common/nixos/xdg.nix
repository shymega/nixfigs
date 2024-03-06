# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs }: {
  xdg.portal = {
    enable = true;
    config.common.default = "gtk";
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-kde xdg-desktop-portal-gnome xdg-desktop-portal-gtk ];
  };
}
