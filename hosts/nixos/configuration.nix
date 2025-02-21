# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:

{
  users = {
    mutableUsers = false;
    users."dzrodriguez" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Dom RODRIGUEZ";
      hashedPasswordFile = config.age.secrets.user_dzrodriguez.path;
      subUidRanges = [{
        startUid = 100000;
        count = 65536;
      }];
      subGidRanges = [{
        startGid = 100000;
        count = 65536;
      }];
      extraGroups = [
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

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false; # Very dodgy!
  };

  services = {
    avahi.enable = true;
    flatpak.enable = true;
    dbus.enable = true;
    openssh.enable = true;
    printing = {
      enable = true;
      browsing = true;
      drivers = with pkgs; [
        epson-escpr
        brlaser
        gutenprint
        gutenprintBin
        hplip
        hplipWithPlugin
        postscript-lexmark
        samsung-unified-linux-driver
        splix
      ];
    };
    saned.enable = true;
    zerotierone.enable = true;
    zerotierone.joinNetworks = [ "159924d6300f2e03" "a09acf023309eb36" "9bee8941b58d20f4" "3efa5cb78ad4744a" ];
    geoclue2.enable = true;
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
      extraConfig = ''
        DNS=1.1.1.1#1dot1dot1dot1.cloudflare-dns.com 1.0.0.1#1dot1dot1dot1.cloudflare-dns.com 2606:4700:4700::1111#1dot1dot1dot1.cloudflare-dns.com 2606:4700:4700::1001#1dot1dot1dot1.cloudflare-dns.com
        DNSOverTLS=opportunistic
      '';
    };
  };

  networking = {
    timeServers = lib.mkForce [ "uk.pool.ntp.org" ];
    firewall.checkReversePath = false;
  };

  programs = {
    zsh.enable = true;
    fish.enable = true;
    adb.enable = true;
    mosh.enable = true;
    dconf.enable = true;
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "dzrodriguez" ];
    };
  };

  virtualisation = {
    spiceUSBRedirection.enable = true;

    docker.enable = true;
    podman.enable = true;

    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = with pkgs.unstable; [
            OVMFFull.fd
          ] ++ (lib.optionals pkgs.stdenv.isx86_64 (with pkgs; [
            pkgsCross.aarch64-multiplatform.OVMF.fd
          ]));
        };
      };
      onBoot = "ignore";
      onShutdown = "suspend";
    };
  };

  environment.shells = with pkgs; [ zsh fish bash ];

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      brlaser
      epson-escpr
      gutenprint
      gutenprintBin
      hplip
      hplipWithPlugin
      postscript-lexmark
      samsung-unified-linux-driver
      splix
    ];
  };

  system.stateVersion = "23.11";
}
