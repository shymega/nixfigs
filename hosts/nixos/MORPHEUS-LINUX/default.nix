# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:
let
  enableXanmod = false;
in
{
  networking.hostName = "MORPHEUS-LINUX";
  networking.hostId = "e8a03c89";

  boot = {
    supportedFilesystems = [ "ntfs" "zfs" ];

    kernelPackages =
      if enableXanmod then
        pkgs.linuxPackages_xanmod_latest
      else
        config.boot.zfs.package.latestCompatibleLinuxPackages;

    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    extraModprobeConfig = ''
      options kvm_amd nested=1
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };

    plymouth = {
      enable = true;
    };

    loader = {
      systemd-boot = {
        enable = false;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi/NIXOS";
      };
      grub = {
        device = "nodev";
        efiSupport = true;
        default = "saved";
        enable = true;
        useOSProber = true;
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

  hardware = {
    opengl = {
      enable = true;
      driSupport = false;
      extraPackages = pkgs.lib.mkForce (with pkgs; [
        amdvlk
      ]);
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    models = "/data/AI/LLMs/Ollama/Models/";
    writablePaths = [ "/data/AI/LLMs/Ollama/Models/" ];
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 780M
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services = {
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
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          deckcheatz
          protontricks
          protonup-qt
          python3Full
          python3Packages.pip
          python3Packages.virtualenv
          steamcmd
          steamtinkerlaunch
          wemod-launcher
          wineWowPackages.stable
          winetricks
        ];
    };
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = false;
  };

  services = {
    ofono = {
      enable = true;
      plugins = [ pkgs.modem-manager-gui pkgs.libsForQt5.modemmanager-qt ];
    };
  };
}
