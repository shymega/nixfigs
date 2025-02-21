# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, ... }: {
  services = {
    xserver = {
      enable = true;
      displayManager.startx.enable = true;
      displayManager = {
        gdm.enable = true;
        gdm.autoSuspend = false;
        defaultSession = "sway";
      };
      libinput.enable = true;
      desktopManager = {
        plasma5.enable = true;
      };
      windowManager = {
        i3.enable = true;
      };
      layout = "us";
    };
  };
}
