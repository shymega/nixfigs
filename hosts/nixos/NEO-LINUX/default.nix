# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:
let
  enableXanmod = false;
in
{
  environment.etc."crypttab".text = ''
    homecrypt /dev/disk/by-label/HOMECRYPT /persist/etc/.homecrypt.bin
  '';
  networking.hostName = "NEO-LINUX";
  networking.hostId = "7f9080b5";

  boot = {
    supportedFilesystems = [ "ntfs" "zfs" ];
    initrd.supportedFilesystems = [ "ntfs" "zfs" ];

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

    zfs.devNodes = "/dev/NEO-LINUX/ROOT";

    kernel.sysctl = {
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
    };

    loader = {
      systemd-boot = {
        enable = false;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
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

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        vaapiVdpau
        rocm-opencl-runtime
        libvdpau-va-gl
      ];
      extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
    };
  };

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    sandbox = false;
    models = "/data/AI/LLMs/Ollama/Models/";
    writablePaths = [ "/data/AI/LLMs/Ollama/Models/" ];
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # 680M.
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
      autoSnapshot.enable = true;
    };
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
    auto-cpufreq.enable = false;
    power-profiles-daemon.enable = pkgs.lib.mkForce false;
    thermald.enable = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
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
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  security = {
    pam.loginLimits = [
      { domain = "*"; item = "nofile"; type = "-"; value = "524288"; }
      { domain = "*"; item = "memlock"; type = "-"; value = "524288"; }
    ];
  };
}
