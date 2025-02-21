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
    initrd.supportedFilesystems = [ "ntfs" "zfs" ];

    kernelParams = pkgs.lib.mkAfter [
      "usbcore.autosuspend-1"
    ];

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
        enable = true;
        memtest86.enable = true;
        netbootxyz.enable = true;
        extraFiles = { "efi/shell/shellx64.efi" = "${pkgs.edk2-uefi-shell}/shell.efi"; };
        extraEntries = {
          "win11.conf" = ''
            title Windows 11
            efi /EFI/SHELL/SHELLX64.EFI
            options -nointerrupt -nomap -noversion HD0b:EFI\MICROSOFT\BOOT\BOOTMGFW.EFI
          '';
          "bazzite.conf" = ''
            title Bazzite (SteamOS)
            efi /EFI/SHELL/SHELLX64.EFI
            options -nointerrupt -nomap -noversion HD0f:EFI\BOOT\BOOTX64.EFI
          '';
          "shell.conf" = ''
            title
            Shell.efi
            efi /EFI/SHELL/SHELLX64.EFI
          '';
        };
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi/NIXOS";
      };
      grub = {
        device = "nodev";
        efiSupport = false;
        default = "saved";
        enableCryptodisk = false;
        enable = false;
        useOSProber = false;
        zfsSupport = false;
      };
      timeout = 6;
    };

    initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [
        "initrd.target"
      ];
      after = [
        "zfs-import-zosroot.service"
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
        zfs
        rollback - r zosroot/crypt/nixos/local/root@blank
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
      autoSnapshot.enable = true;
    };
    xserver = {
      enable = true;
      videoDrivers = [ "amdgpu" ];
    };
    auto-cpufreq.enable = false;
    power-profiles-daemon.enable = pkgs.lib.mkForce false;
    input-remapper.enable = true;
    thermald.enable = true;
    udev = {
      packages = with pkgs; [ gnome.gnome-settings-daemon ];
      extraRules = ''
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery.target"
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ac.target"
      '';
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
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  services = {
    ofono = {
      enable = true;
      plugins = [ pkgs.modem-manager-gui pkgs.libsForQt5.modemmanager-qt ];
    };
  };

  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.extraConfig = ''
    LidSwitchIgnoreInhibited=no
  '';

  hardware.i2c.enable = true;
  hardware.sensor.iio.enable = true;


  security = {
    pam.loginLimits = [
      { domain = "*"; item = "nofile"; type = "-"; value = "524288"; }
      { domain = "*"; item = "memlock"; type = "-"; value = "524288"; }
    ];
  };
}
