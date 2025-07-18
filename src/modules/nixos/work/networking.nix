# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
let
  inherit (lib) checkRoles;
in {
  config = lib.mkIf (checkRoles ["work"] config) {
    # Work-specific network configurations
    networking.networkmanager.ensureProfiles.profiles = {
      "Corporate-WiFi" = {
        connection = {
          id = "Corporate-WiFi";
          type = "wifi";
          autoconnect = true;
        };
        wifi = {
          ssid = "CORP-SECURE";
          security = "wpa-psk";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "@WORK_WIFI_PSK@"; # From secrets
        };
      };
    };

    # Block personal services when in work mode
    networking.firewall.extraCommands = ''
      # Block Syncthing on work systems
      iptables -A OUTPUT -p tcp --dport 22000 -j DROP
      iptables -A OUTPUT -p udp --dport 21027 -j DROP
      
      # Block personal cloud sync services
      iptables -A OUTPUT -d dropbox.com -j DROP
      iptables -A OUTPUT -d drive.google.com -j DROP
    '';

    # Corporate DNS settings
    networking.nameservers = [
      "8.8.8.8" # Replace with corporate DNS
      "8.8.4.4"
    ];

    # Disable IPv6 if required by corporate policy
    networking.enableIPv6 = lib.mkDefault false;
  };
}