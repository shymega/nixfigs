# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ lib
, self
, config
, pkgs
, ...
}:
let
  inherit (lib.my) isNixOS;
  inherit (pkgs.lib) optionals hasSuffix;
in
{
  networking.networkmanager = {
    dns = "systemd-resolved";
    wifi.macAddress = "stable";
    wifi.powersave = true;
    enable = true;
    dispatcherScripts = optionals (isNixOS && hasSuffix "-LINUX" config.networking.hostName) [
      {
        source = "${self}/static/nixos/rootfs/etc/NetworkManager/dispatcher.d/05-wireless-toggle";
        type = "basic";
      }
      {
        source = "${self}/static/nixos/rootfs/etc/NetworkManager/dispatcher.d/10-net-targets";
        type = "basic";
      }
    ];
  };

  programs.nm-applet = {
    enable = true;
    indicator = true;
  };
}
