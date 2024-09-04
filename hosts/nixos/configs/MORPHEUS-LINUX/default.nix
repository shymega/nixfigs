# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:
let
  enableXanmod = false;
in
{
  imports = [ ./hardware-configuration.nix ../../../../modules/nixos/livestream.nix ];

  networking.hostName = "MORPHEUS-LINUX";
  networking.hostId = "e8a03c89";
  nixfigs.services.livestream = {
    enable = true;
  };
  boot = {
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
    zfs.extraPools = [
      "zdata"
      "zosroot"
    ];
    zfs.devNodes = "/dev/disk/by-partuuid";
    zfs.forceImportAll = true;

    initrd.supportedFilesystems = [
      "ntfs"
      "zfs"
    ];

    kernelParams = pkgs.lib.mkAfter [ "usbcore.autosuspend=-1" "nohibernate" ];

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
          ${pkgs.gnused}/bin/sed -i '/default/d' /boot/efi/loader/loader.conf
          echo "default @saved" >> /boot/efi/loader/loader.conf
        '';
        #        rebootForBitlocker = true;
        extraFiles = {
          "efi/shell/shellx64.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
        };
        extraEntries = {
          "shell.conf" = ''
            title UEFI shell
            efi /EFI/SHELL/SHELLX64.EFI
          '';
        };
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      generationsDir.copyKernels = true;
      timeout = 6;
    };

    initrd.systemd.services.rollback = {
      description = "Rollback ZFS datasets to a pristine state";
      wantedBy = [ "initrd.target" ];
      after = [ "zfs-import-zosroot.service" ];
      before = [ "sysroot.mount" ];
      path = with pkgs; [ zfs ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        zfs rollback -r zosroot/crypt/nixos/local/root@blank
      '';
    };
  };

  systemd.services."apply-acpi-wakeup-fixes" = {
    description = "Apply WM2 wakeup fixes";
    wantedBy = [ "basic.target" ];
    path = with pkgs; [ gawk coreutils ];
    serviceConfig.Type = "oneshot";
    script = ''
      for i in $(cat /proc/acpi/wakeup|grep enabled|awk '{print $1}'|xargs); do case $i in SLPB|XHCI);; *) echo $i|tee /proc/acpi/wakeup ; esac; done
    '';
  };


  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport32Bit = true;
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
    graphics = {
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "armv6l-linux"
    "armv7l-linux"
  ];

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
    ollama = {
      enable = true;
      package = pkgs.ollama;
      sandbox = false;
      acceleration = false;
      models = "/data/AI/LLMs/Ollama/Models/";
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 780M.
      };
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
        SUBSYSTEM=="i2c", KERNEL=="i2c-GXTP7385:00", ATTR{power/wakeup}="disabled"
      '';
    };
    ofono = {
      enable = true;
      plugins = [
        pkgs.modem-manager-gui
        pkgs.libsForQt5.modemmanager-qt
      ];
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
      extraPkgs =
        pkgs: with pkgs; [
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
      {
        domain = "*";
        item = "nofile";
        type = "-";
        value = "524288";
      }
      {
        domain = "*";
        item = "memlock";
        type = "-";
        value = "524288";
      }
    ];
  };

  system.stateVersion = "24.05";

}
