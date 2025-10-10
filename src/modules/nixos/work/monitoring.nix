# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) checkRoles;
in {
  config = lib.mkIf (checkRoles ["work"] config) {
    # Corporate monitoring and management
    # Note: Add actual corporate MDM/monitoring tools as needed

    # Enhanced logging for corporate compliance
    services.journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=2G
      SystemKeepFree=1G
      MaxRetentionSec=60day
      Compress=yes
      Seal=yes
    '';

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
  };
}
