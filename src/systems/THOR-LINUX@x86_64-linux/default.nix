# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  latestXanmodKernelPackage = let
    myZfsCompatibleXanmodKernelPackages = let
      zfsIsUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
    in
      lib.filterAttrs (
        name: kernelPackages:
          (lib.hasInfix "_xanmod" name)
          && (builtins.tryEval kernelPackages).success
          && (
            (!zfsIsUnstable && !kernelPackages.${pkgs.zfs.kernelModuleAttribute}.meta.broken)
            || (zfsIsUnstable && !kernelPackages.zfs_unstable.meta.broken)
          )
      )
      pkgs.linuxKernel.packages;
  in
    lib.last (
      lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
        builtins.attrValues myZfsCompatibleXanmodKernelPackages
      )
    );
in {
  imports = with inputs; [
    ./hardware-configuration.nix
    nur-xddxdd.nixosModules.setupOverlay
    nur-xddxdd.nixosModules.nix-cache-attic
    nur-xddxdd.nixosModules.qemu-user-static-binfmt
  ];

  lantian.qemu-user-static-binfmt.enable = true;

  networking = {
    hostName = "THOR-LINUX";
    hostId = "7861be1c";
    usePredictableInterfaceNames = false;
  };
  boot = {
    binfmt = {
      emulatedSystems = [
        "wasm32-wasi"
        "wasm64-wasi"
      ];
    };
    supportedFilesystems = [
      "ntfs"
      "zfs"
    ];
    initrd = {
      supportedFilesystems = [
        "ntfs"
        "zfs"
      ];
      luks = {
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
      };
      systemd.services = {
        rollback = {
          description = "Rollback ZFS datasets to a pristine state";
          wantedBy = ["initrd.target"];
          after = ["zfs-import-ztank.service"];
          before = ["sysroot.mount"];
          path = with pkgs; [zfs];
          serviceConfig.Type = "oneshot";
          script = ''
            zfs rollback -r ztank/crypt/nixos/linux/local/root@blank || true
          '';
        };
      };
    };
    zfs = {
      extraPools = ["ztank" "zdata"];
      devNodes = "/dev/disk/by-uuid";
    };

    kernelParams = let
      zfs_arc_max = 8 * 1024 * 1024 * 1024;
      zfs_arc_min = zfs_arc_max - 1;
    in [
      "nohibernate"
      "zfs.zfs_arc_max=${toString zfs_arc_max}"
      "zfs.zfs_arc_min=${toString zfs_arc_min}"
      "zfs.l2arc_write_boost=33554432"
      "zfs.l2arc_write_max=16777216"
      "microcode.amd_sha_check=off"
      "iomem=relaxed"
    ];
    extraModprobeConfig = ''
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
      theme = "Win2K";
      themePackages = with inputs;
      with pkgs; [
        win2k-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
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
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # VA-API and VDPAU
        libva-vdpau-driver

        # AMD ROCm OpenCL runtime
        rocmPackages.clr
        rocmPackages.clr.icd
      ];
    };
    i2c.enable = false;
    sensor.iio = {
      enable = false;
    };
  };

  services = {
    fwupd.enable = true;
    hardware.bolt.enable = true;
    zfs = {
      trim = {
        enable = true;
        interval = "Sun *-*-* 02:00:00";
      };
      autoScrub = {
        enable = true;
        interval = "Sun *-*-* 02:00:00";
      };
      autoSnapshot.enable = true;
    };
    xserver = {
      enable = true;
      videoDrivers = ["modesetting "];
    };
    ollama = {
      enable = false;
      package = pkgs.ollama;
      acceleration = "rocm";
      models = "/var/lib/ollama";
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "11.0.2"; # 890M-like.
      };
    };
    fstrim.enable = true;
    smartd = {
      enable = true;
      autodetect = true;
    };
    input-remapper.enable = false;
    thermald.enable = true;
    power-profiles-daemon.enable = lib.mkForce false;
    udev = {
      extraRules = ''
        SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="0", RUN+="${pkgs.lib.getExe' pkgs.systemd "systemctl"} --no-block start battery.target"
        SUBSYSTEM=="power_supply", KERNEL=="ACAD", ATTR{online}=="1", RUN+="${pkgs.lib.getExe' pkgs.systemd "systemctl"} --no-block start ac.target"

        # workstation - keyboard & mouse suspension.
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="05ac", ATTRS{idProduct}=="024f", ATTR{power/autosuspend}="-1"
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1bcf", ATTRS{idProduct}=="0005", ATTR{power/autosuspend}="-1"
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="01e0", ATTR{power/autosuspend}="-1"
        ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="5043", ATTRS{idProduct}=="5c46", ATTR{power/autosuspend}="-1"

        # KVM input - active.
        SUBSYSTEM=="usb", ACTION=="add|change|remove", ATTR{idVendor}=="13ba", ATTR{idProduct}=="0018",  SYMLINK+="currkvm", TAG+="systemd"
      '';
    };
    logind = {
      lidSwitchExternalPower = "ignore";
      lidSwitchDocked = "ignore";
      extraConfig = ''
        LidSwitchIgnoreInhibited=no
      '';
    };
  };

  system.stateVersion = "25.05";

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "reset-gpu" ''
      cat /sys/kernel/debug/dri/1/amdgpu_gpu_recover
    '')
  ];
}
