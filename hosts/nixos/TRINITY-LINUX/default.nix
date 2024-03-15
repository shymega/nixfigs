# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
{
  networking.hostName = "TRINITY-LINUX";
  networking.hostId = "65ad6c0b";
  time.timeZone = "Europe/London";

  boot = {
    supportedFilesystems = [ "zfs" "ntfs" ];

    kernelPackages = pkgs.linuxPackages_xanmod_latest;
#    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';

    zfs.devNodes = "/dev/TRINITY-LINUX/ROOT";

    kernel.sysctl = {
      "dev.i915.perf_stream_paranoid" = "0";
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };

    initrd.luks.devices = {
      nixos = {
        device = "/dev/disk/by-label/NIXOS";
        preLVM = true;
        allowDiscards = true;
      };
    };

    plymouth = {
      enable = true;
      themePackages = with pkgs; [ breeze-plymouth ];
      theme = "breeze";
    };

    loader = {
      systemd-boot = {
        enable = false;
      };
      grub = {
        configurationLimit = 5;
        default = "saved";
        device = "nodev";
        efiSupport = true;
        enable = true;
        enableCryptodisk = true;
        extraConfig = ''
          set gfxmode=1200x1920x32
        '';
        gfxmodeBios = "1200x1920x32";
        gfxmodeEfi = "1200x1920x32";
        memtest86.enable = true;
        useOSProber = true;
        zfsSupport = true;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 6;
    };

    initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      after = [
        "zfs-import-tank.service"
      ];
      before = [
        "sysroot.mount"
      ];
      path = with pkgs; [
        zfs
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r tank/local/root@blank
      '';
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
  services = {
    thermald.enable = true;
    power-profiles-daemon.enable = true;
    zfs = {
      trim = {
        enable = true;
        interval = "Sat *-*-* 04:00:00";
      };
      autoScrub = {
        enable = true;
        interval = "Sat *-*-* 05:00:00";
      };
    };
    auto-cpufreq.enable = true;
    logind = {
      extraConfig = ''
        HandleLidSwitchExternalPower=ignore
        LidSwitchIgnoredInhibited=no
      '';
    };
    udev = {
      packages = with pkgs; [ gnome.gnome-settings-daemon ];
      extraHwdb = ''
        sensor:modalias:*
         ACCEL_MOUNT_MATRIX=-0, -1, 0; -1, 0, 0; 0, 0, 1
      '';
      extraRules = ''
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery.target"
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ac.target"
      '';
    };
  };
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages32 = lib.optionals pkgs.stdenv.isi686 (with pkgs.pkgsi686Linux;
        [ vaapiIntel ]);
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
        intel-compute-runtime
      ];
    };
    sensor.iio.enable = true;
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.steam.enable = true;
}
