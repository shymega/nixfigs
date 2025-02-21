# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:
let
  userName = if config.networking.hostName == "MORPHEUS-LINUX" then "dominic.rodriguez" else "dzrodriguez";
in
{
  users = {
    mutableUsers = false;
    users."root".password = "!"; # Lock account.
    users."${userName}" = {
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "Dom RODRIGUEZ";
      hashedPasswordFile = config.age.secrets."user_dominic.rodriguez".path;
      subUidRanges = [{
        startUid = 100000;
        count = 65536;
      }];
      subGidRanges = [{
        startGid = 100000;
        count = 65536;
      }];
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

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false; # Very dodgy!
  };

  location.provider = "geoclue2";

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    flatpak.enable = true;
    dbus.enable = true;
    openssh.enable = true;
    printing = {
      enable = true;
      browsing = true;
      drivers = with pkgs; [
        hplipWithPlugin
        gutenprint
        gutenprintBin
        samsung-unified-linux-driver
        brlaser
      ];
    };
    clight = {
      enable = true;
      settings = {
        gamma = {
          disabled = true;
        };
      };
    };
    guix = {
      enable = true;
    };
    saned.enable = true;
    zerotierone.enable = true;
    zerotierone.joinNetworks = lib.strings.splitString "," (builtins.readFile config.age.secrets.zerotier_networks.path);
    geoclue2 = {
      enable = true;
      enableDemoAgent = lib.mkForce true;
      submissionUrl = lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.geoclue_url.path);
      geoProviderUrl = config.services.geoclue2.submissionUrl;
      appConfig = {
        redshift = {
          isAllowed = true;
          isSystem = false;
        };
        gammastep = {
          isAllowed = true;
          isSystem = false;
        };
      };
    };
    automatic-timezoned.enable = true;
    resolved = {
      enable = true;
      dnsovertls = "opportunistic";
      fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
      extraConfig = ''
        DNS=1.1.1.1#1dot1dot1dot1.cloudflare-dns.com 1.0.0.1#1dot1dot1dot1.cloudflare-dns.com 2606:4700:4700::1111#1dot1dot1dot1.cloudflare-dns.com 2606:4700:4700::1001#1dot1dot1dot1.cloudflare-dns.com
      '';
    };
    usbmuxd = {
      enable = true;
      package = pkgs.usbmuxd2;
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
    xwayland.enable = true;

    _1password = {
      enable = true;
      package = pkgs.unstable._1password;
    };
    _1password-gui = {
      enable = true;
      package = pkgs.unstable._1password-gui;
      polkitPolicyOwners = [ "${userName}" ];
    };
  };

  virtualisation = {
    spiceUSBRedirection.enable = true;

    waydroid.enable = true;
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
          packages = with pkgs; [
            OVMFFull.fd
          ] ++ (lib.optional pkgs.stdenv.isx86_64 pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd);
        };
      };
      onBoot = "ignore";
      onShutdown = "suspend";
    };
  };

  environment.shells = with pkgs; [ zsh fish bash ];

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplipWithPlugin
      epkowa
    ];
  };

  system.stateVersion = "24.05";

  nixfigs = {
    fonts = {
      enable = true;
      xdg.enable = true;
    };
    shells.fish.enable = true;
  };
}
