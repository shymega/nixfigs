# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config
, pkgs
, lib
, ...
}:
{
  imports = [ ./hardware-configuration.nix ./synapse.nix ];

  time.timeZone = "Europe/London";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };
    binfmt.emulatedSystems = [ "x86_64-linux" ];
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
        "944fbebc-5b7e-4702-b6e9-d759a8a7709a" = {
          ingress = {
            "ssh.delta-zero.rodriguez.org.uk".service = "ssh://localhost:22";
          };
          credentialsFile = "/var/lib/cloudflared/944fbebc-5b7e-4702-b6e9-d759a8a7709a.json";
          default = "http_status:404";
        };
      };
    };
    dbus.enable = true;
    taskserver = {
      enable = true;
      fqdn = "taskd.shymega.org.uk";
      openFirewall = true;
      listenHost = "0.0.0.0";
      organisations.shyNET.users = [ "shymega" ];
    };
    zerotierone.enable = true;
    tailscale.enable = true;
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
    resolved.enable = lib.mkForce false;
    unbound = {
      enable = true;
      settings = {
        remote-control.control-enable = true;
        server = {
          # When only using Unbound as DNS, make sure to replace 127.0.0.1 with your ip address
          # When using Unbound in combination with pi-hole or Adguard, leave 127.0.0.1, and point Adguard to 127.0.0.1:PORT
          interface = [ "127.0.0.1" ];
          port = 53;
          access-control = [ "127.0.0.1 allow" ];
          # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;

          # Custom settings
          hide-identity = true;
          hide-version = true;
        };
        forward-zone = [
          # Example config with quad9
          {
            name = ".";
            forward-addr = [
              "8.8.8.8#dns.google"
              "8.8.4.4#dns.google"
            ];
            forward-tls-upstream = true; # Protected DNS
          }
        ];
      };
    };
  };

  networking = {
    hostName = "delta-zero";
    domain = "rodriguez.org.uk";

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
        address = [ "2a01:4f9:c012:80b1::1/64" ];
        routes = [{ routeConfig.Gateway = "fe80::1"; }];
      };
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    podman.enable = lib.mkForce false;
  };

  programs = {
    zsh.enable = true;
    fish.enable = true;
    mosh.enable = true;
  };

  system.stateVersion = "24.05";

  environment.systemPackages = with pkgs; [ dzr-taskwarrior-recur ];

  services.openssh.authorizedKeysFiles = lib.mkOverride 40 [
    "%h/.ssh/authorized_keys"
    "/etc/ssh/authorized_keys.d/%u"
  ];

  services.cron.enable = true;

  users = {
    mutableUsers = false;
    users = {
      "root".password = "!"; # Lock account.
      "dzrodriguez" = {
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
  };
}

