# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:
let
  inherit (lib) checkRoles;
in {
  config = lib.mkIf (checkRoles ["work"] config) {
    # Validation assertions for work systems
    assertions = lib.mkIf (checkRoles ["work"] config) [
    {
      assertion = config.security.auditd.enable;
      message = "Work systems must have audit logging enabled";
    }
    {
      assertion = config.services.fwupd.enable;
      message = "Work systems must have firmware updates enabled";
    }
    {
      assertion = !config.services.syncthing.enable;
      message = "Work systems cannot run personal sync services";
    }
    {
      assertion = config.networking.firewall.enable;
      message = "Work systems must have firewall enabled";
    }
  ];

    # Required security services for corporate compliance
    services.fwupd.enable = true; # Firmware updates
    security.auditd.enable = true; # Audit logging
    
    # System hardening for corporate environments
    security.protectKernelImage = true;
    boot.kernelParams = [ 
      "lockdown=confidentiality"
      "audit=1" 
    ];
    
    # Enable automatic security updates
    system.autoUpgrade = {
      enable = true;
      allowReboot = false; # Don't auto-reboot during work hours
    };
    
    # Enforce strong authentication
    security.pam.services = {
      login.failDelay = 3000000; # 3 second delay on failed login
      passwd.requireWheel = true; # Require wheel group for password changes
    };
    
    # Configure sudo with logging
    security.sudo = {
      enable = true;
      extraConfig = ''
        Defaults logfile=/var/log/sudo.log
        Defaults log_input, log_output
        Defaults timestamp_timeout=0
      '';
    };
    
    # File system security
    boot.tmp.cleanOnBoot = true;
    security.hideProcessInformation = true;
    
    # Network security
    networking.firewall = {
      enable = true;
      logRefusedConnections = true;
    };
    
    # Disable unnecessary services for security
    services = {
      # Disable personal services
      syncthing.enable = lib.mkForce false;
      
      # Security logging
      journald.extraConfig = ''
        SystemMaxUse=1G
        MaxRetentionSec=30day
      '';
    };
  };
}
