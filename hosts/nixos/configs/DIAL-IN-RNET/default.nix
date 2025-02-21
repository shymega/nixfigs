# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  hostname = "dial-in";
  fqdn = "${hostname}.${domain}";
  domain = "rnet.rodriguez.org.uk";
in
{

  imports = [ ./hardware-configuration.nix ];

  time.timeZone = "Europe/London";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  services = {
    cloudflared = {
      enable = true;
      package = pkgs.unstable.cloudflared;
      tunnels = {
        "2d28367c-b672-43e3-b2db-74b13a402797" = {
          ingress = {
            "ssh.dial-in.rnet.rodriguez.org.uk".service = "ssh://localhost:22";
          };
          credentialsFile = "/var/lib/cloudflared/2d28367c-b672-43e3-b2db-74b13a402797.json";
          default = "http_status:404";
        };
        "9a7340e1-969f-434f-88b9-477b130bb791" = {
          ingress = {
            "vpn.dial-in.rnet.rodriguez.org.uk" = "ssh://localhost:22";
          };
          credentialsFile = "/var/lib/cloudflared/9a7340e1-969f-434f-88b9-477b130bb791.json";
          default = "http_status:404";
          credentialsFile = "/var/lib/cloudflared/2d28367c-b672-43e3-b2db-74b13a402797.json";
        };
        "9a7340e1-969f-434f-88b9-477b130bb791" = {
          ingress = {
            "vpn.dial-in.rnet.rodriguez.org.uk".service = "http://localhost:8080";
          };
          default = "http_status:404";
          credentialsFile = "/var/lib/cloudflared/9a7340e1-969f-434f-88b9-477b130bb791.json";
        };
      };
    };
    zerotierone.enable = false;
    tailscale.enable = lib.mkForce false;
    cloud-init.enable = lib.mkForce false;
    fail2ban = {
      enable = true;
      maxretry = 2;
      ignoreIP = [
        "217.155.6.253"
        "2a02:8012:ade3:0:69c3:6693:9253:19c7"
      ];
      bantime = "30m";
      bantime-increment.enable = true;
    };
    resolved = {
      enable = true;
      dnsovertls = "opportunistic";
      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
      extraConfig = ''
        DNS=1.1.1.1#1dot1dot1dot1.cloudflare-dns.com 1.0.0.1#1dot1dot1dot1.cloudflare-dns.com 2606:4700:4700::1111#1dot1dot1dot1.cloudflare-dns.com 2606:4700:4700::1001#1dot1dot1dot1.cloudflare-dns.com
      '';
    };
  };
  networking = {
    hostName = "dial-in";
    domain = "rnet.rodriguez.org.uk";

    timeServers = lib.mkForce [ "uk.pool.ntp.org" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
      checkReversePath = false;
      extraCommands = ''
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 103.21.244.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 103.22.200.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 103.31.4.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 104.16.0.0/13 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 104.24.0.0/14 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 108.162.192.0/18 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 131.0.72.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 141.101.64.0/18 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 162.158.0.0/15 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 172.64.0.0/13 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 173.245.48.0/20 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 188.114.96.0/20 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 190.93.240.0/20 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 197.234.240.0/22 -j ACCEPT
                	iptables -I INPUT -p tcp -m multiport --dports http,https -s 198.41.128.0/17 -j ACCEPT
                	
        	        ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2400:cb00::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2405:8100::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2405:b500::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2606:4700::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2803:f800::/32 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2a06:98c0::/29 -j ACCEPT
                	ip6tables -I INPUT -p tcp -m multiport --dports http,https -s 2c0f:f248::/32 -j ACCEPT
      '';
    };
  };

  systemd = {
    network = {
      enable = true;
      networks."10-hetzner" = {
        matchConfig.Name = "enp1s0";
        networkConfig.DHCP = "ipv4";
        address = [ "2a01:4f9:c012:9802::1/64" ];
        routes = [{ routeConfig.Gateway = "fe80::1"; }];
      };
    };
  };

  programs = {
    zsh.enable = true;
    fish.enable = true;
    mosh.enable = true;
  };

  system.stateVersion = "24.05";

  services.openssh.authorizedKeysFiles = lib.mkOverride 40 [
    "%h/.ssh/authorized_keys"
    "/etc/ssh/authorized_keys.d/%u"
  ];

  security.acme = {
    defaults = {
      email = "rnet+certs@rodriguez.org.uk";
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_KEY_FILE" = config.age.secrets.cloudflare_dns_token.path;
      };
    };
    certs."${fqdn}" = {
      group = "nginx";
    };
    acceptTerms = true;
  };

  services = {
    headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8080;
      settings = {
        logtail.enabled = false;
        dns_config = { baseDomain = "rnet.rodriguez.org.uk"; };
        server_url = "https://${fqdn}";
      };
    };

    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      virtualHosts.${fqdn} = {
        listen = [
          { addr = "[::]"; port = 443; ssl = true; }
          { addr = "0.0.0.0"; port = 443; ssl = true; }
        ];
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass =
              "http://127.0.0.1:8080";
            proxyWebsockets = true;
          };
        };
      };
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  users = {
    mutableUsers = false;
    users."root".password = "!"; # Lock account.
    users."dzrodriguez" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Dom RODRIGUEZ";
      hashedPasswordFile = config.age.secrets.dzrodriguez.path;
      linger = true;
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
      extraGroups = [
        "i2c"
        "adbusers"
        "dialout"
        "disk"
        "docker"
        "input"
        "kvm"
        "libvirt"
        "libvirtd"
        "lp"
        "lpadmin"
        "networkmanager"
        "plugdev"
        "qemu-libvirtd"
        "scanner"
        "systemd-journal"
        "uucp"
        "video"
        "wheel"
      ];
    };
  };
}
