# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:
let
  inherit (config.nixfigs.roles) checkRoles;
  isVM = checkRoles ["virtual-machine"] config;
in {
  config = lib.mkIf isVM {
    # Rustdesk service configuration
    systemd.services.rustdesk = {
      enable = true;
      description = "Rustdesk remote desktop service";
      after = [ "network.target" "graphical-session.target" ];
      wantedBy = [ "multi-user.target" ];
      
      environment = {
        DISPLAY = ":0";
        WAYLAND_DISPLAY = "wayland-0";
        # Restrict to local network access only
        RUSTDESK_SERVER = "192.168.122.1"; # Host IP
      };
      
      serviceConfig = {
        Type = "simple";
        User = "domrodriguez";
        Group = "users";
        ExecStart = "${pkgs.rustdesk}/bin/rustdesk --service";
        Restart = "always";
        RestartSec = 5;
        
        # Security restrictions
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        
        # Network restrictions
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        
        # Capabilities needed for remote desktop
        AmbientCapabilities = [ "CAP_SYS_PTRACE" ];
        CapabilityBoundingSet = [ "CAP_SYS_PTRACE" ];
      };
    };

    # Rustdesk configuration
    environment.etc."rustdesk/rustdesk.toml".text = ''
      [options]
      # Network configuration
      listen-address = "0.0.0.0:21116"
      
      # Security settings
      password = "vmaccess2024" # Change this password
      encryption = true
      
      # Display settings
      video-codec = "h264"
      quality = "balanced"
      
      # Access control - restrict to local network
      whitelist = ["192.168.122.0/24"]
      
      # Logging
      log-level = "info"
      log-file = "/var/log/rustdesk.log"
      
      [server]
      # Use local relay server if available
      relay-server = "192.168.122.1:21117"
      
      [display]
      # VM display optimizations
      capture-cursor = true
      show-cursor = true
      privacy-mode = false
    '';

    # Create rustdesk user configuration directory
    systemd.tmpfiles.rules = [
      "d /home/domrodriguez/.config/rustdesk 0755 domrodriguez users -"
      "d /var/log/rustdesk 0755 domrodriguez users -"
    ];

    # Rustdesk desktop integration
    environment.systemPackages = with pkgs; [
      rustdesk
    ];

    # XDG autostart for Rustdesk GUI (if needed)
    environment.etc."xdg/autostart/rustdesk.desktop".text = ''
      [Desktop Entry]
      Name=Rustdesk
      Comment=Remote Desktop Access
      Exec=${pkgs.rustdesk}/bin/rustdesk --service
      Icon=rustdesk
      Terminal=false
      Type=Application
      StartupNotify=false
      X-GNOME-Autostart-enabled=true
      Hidden=false
    '';

    # Wayland/X11 compatibility for remote desktop
    programs.xwayland.enable = true;
    
    # Enable screen sharing permissions
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "*";
    };

    # Audio forwarding for remote desktop
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Log rotation for Rustdesk
    services.logrotate.settings.rustdesk = {
      files = [ "/var/log/rustdesk.log" ];
      frequency = "daily";
      rotate = 7;
      compress = true;
      delaycompress = true;
      missingok = true;
      notifempty = true;
      create = "644 domrodriguez users";
    };

    # Network security for Rustdesk
    networking.firewall = {
      # Only allow Rustdesk from specific networks
      interfaces."virbr0" = {
        allowedTCPPorts = [ 21116 21117 ];
        allowedUDPPorts = [ 21116 ];
      };
    };

    # Monitoring script for Rustdesk connection
    systemd.services.rustdesk-monitor = {
      enable = true;
      description = "Monitor Rustdesk service health";
      after = [ "rustdesk.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "domrodriguez";
        ExecStart = pkgs.writeShellScript "rustdesk-monitor" ''
          #!/bin/sh
          # Check if Rustdesk is running and accessible
          if ! pgrep -f rustdesk > /dev/null; then
            echo "$(date): Rustdesk service not running" >> /var/log/rustdesk-monitor.log
            systemctl restart rustdesk
          fi
          
          # Log connection attempts
          netstat -tn | grep :21116 | wc -l >> /var/log/rustdesk-connections.log
        '';
      };
    };

    # Timer for Rustdesk monitoring
    systemd.timers.rustdesk-monitor = {
      enable = true;
      description = "Run Rustdesk monitoring every 5 minutes";
      timerConfig = {
        OnCalendar = "*:0/5"; # Every 5 minutes
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}