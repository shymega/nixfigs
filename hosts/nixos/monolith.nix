# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  config,
  lib,
  libx,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../modules/nixos/secrets.nix
    ../../modules/nixos/roles.nix
    inputs.nixfigs-common.common.nixos
  ];
  users = {
    mutableUsers = false;
    users."root".password = "!"; # Lock account.
    users."dzrodriguez" = {
      uid = 1000;
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

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false; # Very dodgy!
  };

  location.provider = "geoclue2";

  services = {
    udisks2.enable = lib.mkDefault false;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    flatpak.enable = true;
    dbus.enable = true;
    openssh.enable = true;
    upower.enable = lib.mkForce true;
    printing = lib.optionalAttrs libx.isPC {
      enable = true;
      browsed.enable = true;
      drivers = with pkgs; [
        hplipWithPlugin
        gutenprint
        gutenprintBin
        samsung-unified-linux-driver
        brlaser
        brgenml1lpr
        brgenml1cupswrapper
      ];
    };
    guix = {
      enable = true;
    };
    zerotierone = {
      enable = true;
      joinNetworks = ["@secret@"];
    };
    geoclue2 = {
      enable = true;
      enableDemoAgent = lib.mkForce true;
      submissionUrl = "@secret@";
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
      fallbackDns = [
        "1.1.1.1"
        "1.0.0.1"
      ];
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
    timeServers = lib.mkForce ["uk.pool.ntp.org"];
    usePredictableInterfaceNames = lib.mkForce false;

    firewall = {
      enable = true;
      interfaces."podman+".allowedUDPPorts = [53];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      checkReversePath = false;
    };
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
      package = pkgs._1password-cli;
    };
    _1password-gui = {
      enable = true;
      package = pkgs._1password-gui;
      polkitPolicyOwners = ["dzrodriguez"];
    };
  };

  virtualisation = {
    podman = {
      autoPrune.enable = true;
      defaultNetwork.settings = {
        # Required for container networking to be able to use names.
        dns_enabled = true;
      };
      enable = true;
    };

    oci-containers.backend = "docker";
    spiceUSBRedirection.enable = true;

    waydroid.enable = true;
    docker.enable = true;
    lxc.enable = true;
    lxd.enable = true;
    vmware.host.enable = true;

    libvirtd = lib.optionalAttrs pkgs.stdenv.isx86_64 {
      enable = true;
      qemu = {
        package = pkgs.qemu_full;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = with pkgs; [
            (OVMFFull.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
            pkgsCross.aarch64-multiplatform.OVMF.fd
          ];
        };
      };
      onBoot = "ignore";
      parallelShutdown = 5;
      onShutdown = "suspend";
    };
  };

  system.stateVersion = "25.05";

  fonts.enableDefaultPackages = true;
  nixfigs = {
    fonts = {
      enable = true;
      xdg.enable = true;
    };
  };
}
