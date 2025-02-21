# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  services = {
    displayManager.defaultSession = "sway";
    xserver = {
      enable = true;
      displayManager = {
        startx.enable = true;
        gdm = {
          enable = true;
          autoSuspend = false;
        };
      };

      desktopManager = {
        plasma5.enable = true;
      };
      xkb.layout = "us";
    };
    libinput.enable = true;
  };
}
