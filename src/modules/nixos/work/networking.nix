# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
let
  inherit (lib) checkRoles;
in {
  config = lib.mkIf (checkRoles ["work"] config) {
    # Block personal services when in work mode
    networking.firewall.extraCommands = ''
      # Block Syncthing on work systems
      iptables -A OUTPUT -p tcp --dport 22000 -j DROP
      iptables -A OUTPUT -p udp --dport 21027 -j DROP
      
      # Block personal cloud sync services
      iptables -A OUTPUT -d dropbox.com -j DROP
      iptables -A OUTPUT -d drive.google.com -j DROP
    '';

    # Disable IPv6 if required by corporate policy
    networking.enableIPv6 = lib.mkDefault false;
  };
}
