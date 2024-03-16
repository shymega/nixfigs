# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ self, pkgs, inputs, ... }:
let
  inherit (pkgs.stdenvNoCC) isLinux;
  inherit (pkgs.lib) optionals;
  isNixOS = builtins.pathExists "/etc/nixos" && builtins.pathExists "/nix" && isLinux;
in
{
  imports = [
    inputs.networkmanager-profiles
  ];
  networking.networkmanager = {
    dns = "systemd-resolved";
    wifi.macAddress = "stable";
    wifi.powersave = true;
    enable = true;
    dispatcherScripts = optionals isNixOS [
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
