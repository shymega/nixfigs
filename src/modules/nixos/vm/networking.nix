# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
let
  inherit (config.nixfigs.roles) checkRoles;
  isVM = checkRoles ["virtual-machine"] config;
in {
  config = lib.mkIf isVM {
    # VM-specific networking
    networking = {
      # Use NetworkManager for easier VM network management
      networkmanager.enable = true;
      
      # Disable systemd-networkd (conflicts with NetworkManager)
      useNetworkd = false;
      
      # VM hostname
      hostName = "ct-vm-domrodriguez";
      
      # Enable IPv6
      enableIPv6 = true;
      
      # Firewall configuration for VM
      firewall = {
        enable = true;
        
        # Allow Rustdesk ports
        allowedTCPPorts = [
          21116 # Rustdesk TCP port
          21117 # Rustdesk TCP port (backup)
        ];
        allowedUDPPorts = [
          21116 # Rustdesk UDP port
        ];
        
        # Allow SSH for management
        allowedTCPPorts = [ 22 ] ++ config.networking.firewall.allowedTCPPorts;
        
        # Custom rules for host-only access
        extraCommands = ''
          # Allow all traffic from host (assuming host is in 192.168.122.0/24 range)
          iptables -A INPUT -s 192.168.122.1 -j ACCEPT
          
          # Allow Rustdesk from libvirt network only
          iptables -A INPUT -s 192.168.122.0/24 -p tcp --dport 21116 -j ACCEPT
          iptables -A INPUT -s 192.168.122.0/24 -p tcp --dport 21117 -j ACCEPT
          iptables -A INPUT -s 192.168.122.0/24 -p udp --dport 21116 -j ACCEPT
          
          # Block Rustdesk from external networks
          iptables -A INPUT -p tcp --dport 21116 -j DROP
          iptables -A INPUT -p tcp --dport 21117 -j DROP
          iptables -A INPUT -p udp --dport 21116 -j DROP
        '';
      };
    };

    # SSH configuration for VM management
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PubkeyAuthentication = true;
      };
    };

    # Network time synchronization
    services.chrony = {
      enable = true;
      servers = [
        "pool.ntp.org"
      ];
    };

    # VM-specific network optimizations
    boot.kernel.sysctl = {
      # Network optimizations for VMs
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 65536 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      
      # Reduce network latency in VMs
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "fq";
    };
  };
}