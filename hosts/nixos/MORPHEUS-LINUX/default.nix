# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:
let
  enableXanmod = true;
in
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "MORPHEUS-LINUX";
  networking.hostId = "e8a03c89";
  boot = {
    supportedFilesystems = [ "ntfs" "zfs" ];
    zfs.extraPools = [ "zdata" "zosroot" ];
    zfs.devNodes = "/dev/disk/by-partuuid/";

    initrd.supportedFilesystems = [ "ntfs" "zfs" ];

    kernelParams = pkgs.lib.mkAfter [
      "usbcore.autosuspend-1"
    ];

    kernelPackages =
      if enableXanmod then
        pkgs.linuxPackages_xanmod
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
      theme = "spinner";
    };

    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
        netbootxyz.enable = true;
        extraInstallCommands = ''
          ${pkgs.gnused}/bin/sed -i '/default/d' /boot/efi/NIXOS/loader/loader.conf
          echo "default @saved" >> /boot/efi/NIXOS/loader/loader.conf
          echo "reboot-for-bitlocker yes" >> /boot/efi/NIXOS/loader/loader.conf
        '';
        #        rebootForBitlocker = true;
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
            title UEFI shell
            efi /EFI/SHELL/SHELLX64.EFI
          '';
        };
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi/NIXOS";
      };
      generationsDir.copyKernels = true;
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
        zfs rollback -r zosroot/crypt/nixos/local/root@blank
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
    i2c.enable = true;
    sensor.iio.enable = true;
    cpu.amd.ryzen-smu.enable = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" "armv6l-linux" "armv7l-linux" ];

  programs = {
    auto-cpufreq = {
      enable = true;
      settings = {
        charger = {
          governor = "performance";
          turbo = "auto";
        };

        battery = {
          governor = "powersave";
          turbo = "auto";
        };
      };
    };
  };

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
    ollama = {
      enable = true;
      package = pkgs.unstable.ollama;
      acceleration = "rocm";
      sandbox = false;
      models = "/data/AI/LLMs/Ollama/Models/";
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 780M.
      };
    };
    upower.enable = true;
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
      '';
    };
    ofono = {
      enable = true;
      plugins = [ pkgs.modem-manager-gui pkgs.libsForQt5.modemmanager-qt ];
    };
    logind = {
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
      extraConfig = ''
        LidSwitchIgnoreInhibited=no
      '';
    };
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          #          deckcheatz
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
