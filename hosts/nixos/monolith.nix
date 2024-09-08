# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ config
, lib
, libx
, pkgs
, ...
}:
{
  imports = [ ../../modules/nixos/secrets.nix ];
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
      enable = false;
      settings = {
        gamma = {
          disabled = true;
        };
      };
    };
    guix = {
      enable = true;
    };
    zerotierone = {
      enable = true;
      joinNetworks = [ "@secret@" ];
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
      polkitPolicyOwners = [ "dzrodriguez" ];
    };
  };

  virtualisation = {
    spiceUSBRedirection.enable = true;

    waydroid.enable = true;
    docker.enable = true;
    podman.enable = true;
    lxc.enable = true;
    lxd.enable = true;

    libvirtd = lib.optionalAttrs pkgs.stdenv.isx86_64 {
      enable = true;
      qemu = {
        package = pkgs.qemu_full;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = lib.optionalAttrs pkgs.stdenv.isx86_64 {
          enable = true;
          packages = with pkgs; [
            (OVMFFull.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
            pkgsCross.aarch64-multiplatform.OVMF.fd
          ];
        };
      };
      onBoot = "ignore";
      parallelShutdown = 5;
      onShutdown = "suspend";
    };
  };

  system.stateVersion = "24.05";

  nixfigs = {
    fonts = {
      enable = true;
      xdg.enable = true;
    };
  };

  programs.nix-ld.enable = true;
  environment.variables = {
    NIX_LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath [
      stdenv.cc.cc
      openssl
      xorg.libXcomposite
      xorg.libXtst
      xorg.libXrandr
      xorg.libXext
      xorg.libX11
      xorg.libXfixes
      libGL
      libva
      pipewire.lib
      xorg.libxcb
      xorg.libXdamage
      xorg.libxshmfence
      xorg.libXxf86vm
      libelf

      # Required
      glib
      gtk2
      bzip2

      # Without these it silently fails
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXi
      xorg.libSM
      xorg.libICE
      gnome2.GConf
      nspr
      nss
      cups
      libcap
      SDL2
      libusb1
      dbus-glib
      ffmpeg
      # Only libraries are needed from those two
      libudev0-shim

      # Verified games requirements
      xorg.libXt
      xorg.libXmu
      libogg
      libvorbis
      SDL
      SDL2_image
      glew110
      libidn
      tbb

      # Other things from runtime
      flac
      freeglut
      libjpeg
      libpng
      libpng12
      libsamplerate
      libmikmod
      libtheora
      libtiff
      pixman
      speex
      SDL_image
      SDL_ttf
      SDL_mixer
      SDL2_ttf
      SDL2_mixer
      libappindicator-gtk2
      libdbusmenu-gtk2
      libindicator-gtk2
      libcaca
      libcanberra
      libgcrypt
      libvpx
      librsvg
      xorg.libXft
      libvdpau
      gnome2.pango
      cairo
      atk
      gdk-pixbuf
      fontconfig
      freetype
      dbus
      alsaLib
      expat
      # Needed for electron
      libdrm
      mesa
      libxkbcommon
    ];
    NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  };
}
