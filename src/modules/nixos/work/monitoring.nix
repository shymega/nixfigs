# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:
let
  inherit (lib) checkRoles;
in {
  config = lib.mkIf (checkRoles ["work"] config) {
    # Corporate monitoring and management
    # Note: Add actual corporate MDM/monitoring tools as needed
    
    # System monitoring and logging
    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes" 
          "network_route"
          "filesystem"
        ];
        disabledCollectors = [
          "textfile" # Disable to prevent information leakage
        ];
        openFirewall = false; # Keep monitoring internal
      };
    };
    
    # Enhanced logging for corporate compliance
    services.journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=2G
      SystemKeepFree=1G
      MaxRetentionSec=60day
      Compress=yes
      Seal=yes
    '';
    
    # Network monitoring
    services.netdata = {
      enable = true;
      config = {
        global = {
          "default port" = "19999";
          "bind to" = "127.0.0.1"; # Local access only
        };
        web = {
          "mode" = "none"; # Disable web interface for security
        };
      };
    };
    
    # Security event monitoring
    services.fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      jails = {
        ssh = ''
          enabled = true
          port = ssh
          filter = sshd
          logpath = /var/log/auth.log
          maxretry = 3
          bantime = 3600
        '';
      };
    };
    
    # Corporate time synchronization
    services.chrony = {
      enable = true;
      servers = [
        "time.nist.gov" # Replace with corporate NTP servers
        "pool.ntp.org"
      ];
    };
    
    # Placeholder for corporate monitoring agent
    # Uncomment and configure when corporate monitoring is available
    /*
    systemd.services.corporate-agent = {
      enable = true;
      description = "Corporate monitoring agent";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "corporate-agent" ''
          # Placeholder script for corporate monitoring
          # Replace with actual corporate monitoring agent
          echo "Corporate monitoring agent would run here"
          sleep infinity
        ''}";
        Restart = "always";
        RestartSec = 30;
        User = "root";
      };
      wantedBy = [ "multi-user.target" ];
    };
    */
  };
}