# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  zfsIsUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
  myZfsCompatibleXanmodKernelPackages =
    lib.filterAttrs (
      name: kernelPackages:
        (lib.hasInfix "_xanmod" name)
        && (builtins.tryEval kernelPackages).success
        && (
          (!zfsIsUnstable && !kernelPackages.${pkgs.zfs.kernelModuleAttribute}.meta.broken)
          || (zfsIsUnstable && !kernelPackages.zfs_unstable.meta.broken)
        )
    )
    pkgs.unstable.linuxKernel.packages;
  latestXanmodKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues myZfsCompatibleXanmodKernelPackages
    )
  );
  zfs_arc_max = toString (8 * 1024 * 1024 * 1024);
  zfs_arc_min = toString (8 * 1024 * 1024 * 1024 - 1);
in {
  imports = with inputs; [
    ./hardware-configuration.nix
    ucodenix.nixosModules.default
    nur-xddxdd.nixosModules.setupOverlay
    nur-xddxdd.nixosModules.nix-cache-attic
    nixfigs-virtual-private.virtual.all
  ];
  services.ucodenix = {
    enable = true;
    cpuModelId = "00A70F52";
  };

  networking = {
    hostName = "MORPHEUS-LINUX";
    hostId = "c4e0feaa";
    usePredictableInterfaceNames = false;
  };
  boot = {
    zfs = {
      extraPools = ["ztank" "zdata"];
      devNodes = "/dev/disk/by-uuid";
    };
    binfmt = {
      emulatedSystems = [
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "riscv64-linux"
        "wasm32-wasi"
        "wasm64-wasi"
      ];
      registrations."riscv64-linux" = {
        wrapInterpreterInShell = false;
        preserveArgvZero = true;
        matchCredentials = true;
        fixBinary = true;
      };
    };
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];

    initrd.luks = {
      devices = {
        OS_CRYPTO = {
          device = "/dev/disk/by-label/OS_CRYPTO";
          preLVM = true;
          allowDiscards = true;
        };
        DATA = {
          device = "/dev/disk/by-label/DATA";
          preLVM = true;
          allowDiscards = true;
        };
      };
      # Add FIDO2 support.
    };
    initrd.supportedFilesystems = [
      "ntfs"
      "zfs"
    ];

    kernelParams = pkgs.lib.mkAfter [
      "amdgpu"
      "amd_pstate=guided"
      "nohibernate"
      "zfs.zfs_arc_max=${zfs_arc_max}"
      "zfs.zfs_arc_min=${zfs_arc_min}"
      "zfs.l2arc_write_boost=33554432"
      "zfs.l2arc_write_max=16777216"
    ];
    extraModprobeConfig = lib.mkAfter ''
      options kvm_amd nested=1
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';

    kernelPackages = latestXanmodKernelPackage;
    extraModulePackages = [config.boot.kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}];

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "819200";
      "kernel.printk" = "3 3 3 3";
    };

    plymouth = {
      enable = true;
      theme = "spinner";
    };

    lanzaboote = {
      enable = false; # TODO: Reenable once `extraEntries` available upstream.
      enrollKeys = false;
      configurationLimit = 3;
      pkiBundle = "/etc/secureboot";
    };
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
        netbootxyz.enable = true;
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

    initrd.systemd.services = {
      rollback = {
        description = "Rollback ZFS datasets to a pristine state";
        wantedBy = ["initrd.target"];
        after = ["zfs-import-ztank.service"];
        before = ["sysroot.mount"];
        path = with pkgs; [zfs];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r ztank/crypt/nixos/linux/local/root@blank
        '';
      };
      create-needed-for-boot-dirs = {
        after = pkgs.lib.mkForce [
          "zfs-import-zdata.service"
          "zfs-import-ztank.service"
        ];
        wants = pkgs.lib.mkForce [
          "zfs-import-zdata.service"
          "zfs-import-ztank.service"
        ];
      };
    };
  };

  systemd.services."apply-acpi-wakeup-fixes" = {
    description = "Apply WM2 wakeup fixes";
    wantedBy = ["basic.target"];
    path = with pkgs; [
      gawk
      coreutils
    ];
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
    gpd.ppt.enable = lib.mkForce false;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        # VA-API and VDPAU
        vaapiVdpau

        # AMD ROCm OpenCL runtime
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
      extraPackages32 = with pkgs; [driversi686Linux.amdvlk];
    };
    amdgpu = {
      initrd.enable = true;
      amdvlk = {
        enable = true;
        support32Bit.enable = true;
      };
      opencl.enable = true;
    };
    i2c.enable = true;
    sensor.iio = {
      enable = true;
      bmi260.enable = true;
    };
    cpu.amd.ryzen-smu.enable = true;
  };

  services = {
    power-profiles-daemon.enable = pkgs.lib.mkForce false;
    fwupd.enable = true;
    hardware.bolt.enable = true;
    handheld-daemon = {
      enable = false;
      package = pkgs.handheld-daemon;
      user = "dzrodriguez";
    };
    zfs = {
      trim = {
        enable = true;
        interval = "Sun *-*-* 03:00:00";
      };
      autoScrub = {
        enable = true;
        interval = "Sun *-*-* 02:00:00";
      };
      autoSnapshot.enable = true;
    };
    xserver = {
      enable = true;
      videoDrivers = ["amdgpu"];
    };
    ollama = {
      enable = false;
      package = pkgs.ollama;
      acceleration = "rocm";
      models = "/data/AI/LLMs/Ollama/Models/";
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.0"; # 780M.
      };
    };
    fstrim.enable = false;
    smartd = {
      enable = true;
      autodetect = true;
    };
    input-remapper.enable = true;
    thermald.enable = true;
    udev = {
      packages = with pkgs; [gnome-settings-daemon];
      extraRules = ''
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="0", RUN+="${pkgs.lib.getExe' pkgs.systemd "systemctl"} --no-block start battery.target"
        SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="1", RUN+="${pkgs.lib.getExe' pkgs.systemd "systemctl"} --no-block start ac.target"

        # workstation - keyboard & mouse suspension.
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="024f", ATTR{power/autosuspend}:="-1" # Keychron C2.
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1bcf", ATTRS{idProduct}=="0005", ATTR{power/autosuspend}:="-1" # Optical mouse (generic)
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="01e0", ATTR{power/autosuspend}:="-1" # Keychron Q11.
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="5043", ATTRS{idProduct}=="5c46", ATTR{power/autosuspend}:="-1" # Ploopy.

        # 4g lte modem.
        ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="2c7c", ATTR{idProduct}=="0125", ATTR{power/autosuspend}="-1"

        # workstation - thinkpad dock (40ac).
        SUBSYSTEM=="usb", ACTION=="add|change", ATTR{idVendor}=="17ef", ATTR{idProduct}=="3066", SYMLINK+="docked", SYMLINK+="docked", TAG+="systemd"

        # kvm input - active.
        SUBSYSTEM=="usb", ACTION=="add|change|remove", ATTR{idVendor}=="13ba", ATTR{idProduct}=="0018",  SYMLINK+="currkvm", TAG+="systemd"

        # my personal iphone.
        SUBSYSTEM=="net", ACTION=="add|change", DRIVERS=="?*", ENV{ID_MODEL_ID}=="12a8", KERNEL=="eth*", name="iphone0"

        # my personal op6t.
        SUBSYSTEM=="net", ACTION=="add|change", DRIVERS=="?*", ENV{ID_MODEL_ID}=="9024", KERNEL=="usb*", name="android0"

        # wm2 i2c fixes.
        SUBSYSTEM=="i2c", KERNEL=="i2c-gxtp7385:00", ATTR{power/wakeup}="disabled"
      '';
    };
    logind = {
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
      extraConfig = ''
        LidSwitchIgnoreInhibited=no
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
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          steamtinkerlaunch
        ];
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  system.stateVersion = "25.05";
}
