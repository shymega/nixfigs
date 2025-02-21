# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, config, pkgs, ... }:
let
  enableXanmod = true;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.jovian-nixos.nixosModules.default
  ];

  networking = {
    hostName = "TRINITY-JOVIAN";
    hostId = "a200804d";
  };
  boot = {
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
    zfs.extraPools = [
      "ztank"
    ];
    zfs.devNodes = "/dev/disk/by-partuuid";

    initrd.supportedFilesystems = [
      "ntfs"
      "zfs"
    ];

    kernelPackages =
      if enableXanmod then
        pkgs.linuxPackages_xanmod
      else
        config.boot.zfs.package.latestCompatibleLinuxPackages;

    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };

  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  environment.variables = {
    # VAAPI and VDPAU config for accelerated video.
    # See https://wiki.archlinux.org/index.php/Hardware_video_acceleration
    "VDPAU_DRIVER" = "radeonsi";
    "LIBVA_DRIVER_NAME" = "radeonsi";
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages = with pkgs.unstable; [
        amdvlk
        rocm-opencl-icd
        vaapiVdpau
        rocm-opencl-runtime
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.unstable; [
        driversi686Linux.amdvlk
      ];
    };
    i2c.enable = true;
    cpu.amd.ryzen-smu.enable = true;
  };
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
  ];

  services = {
    handheld-daemon = {
      enable = true;
      package = pkgs.handheld-daemon;
      user = "dzrodriguez";
    };
    zfs = {
      trim = {
        enable = true;
        interval = "Sat *-*-* 04:00:00";
      };
      autoScrub = {
        enable = true;
        interval = "Sat *-*-* 05:00:00";
      };
      autoSnapshot.enable = true;
    };
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
    fstrim.enable = true;
    smartd = {
      enable = true;
      autodetect = true;
    };
    power-profiles-daemon.enable = true;
    input-remapper.enable = true;
    thermald.enable = true;
    udev = {
      packages = with pkgs; [ gnome.gnome-settings-daemon ];
      extraRules = ''
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery.target"
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ac.target"

        # Workstation - keyboard & mouse
        ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="024f", ATTR{power/autosuspend}="-1"
        ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1bcf", ATTR{idProduct}=="0005", ATTR{power/autosuspend}="-1"

        # Workstation - docked.
        SUBSYSTEM=="usb", ACTION=="add|change", ATTR{idVendor}=="17ef", ATTR{idProduct}=="3060", SYMLINK+="homeofficedock", TAG+="systemd"
      '';
    };
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };
  };

  jovian = {
    steam = {
      enable = false;
      autoStart = false;
      user = "dzrodriguez";
    };
    decky-loader = {
      enable = true;
      user = "dzrodriguez";
    };
    devices.steamdeck = {
      autoUpdate = true;
      enable = true;
      enableGyroDsuService = true;
    };
  };

  system.stateVersion = "24.05";
}
