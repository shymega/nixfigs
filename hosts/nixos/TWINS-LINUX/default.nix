{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-x270
    ./hardware-configuration.nix
  ];

  networking.hostName = "TWINS-LINUX";
  time.timeZone = "Europe/London";
  networking.hostId = "b0798d56";

  boot = {
    supportedFilesystems = [ "ntfs" "zfs" ];

#    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    extraModulePackages = with config.boot.kernelPackages; [ zfs ];

    zfs.devNodes = "/dev/TWINS-LINUX/ROOT";

    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1 report_ignored_msrs=0
    '';

    kernelParams = lib.mkAfter [
      "loglevel=3"
      "quiet"
      "rd.udev.log_level=3"
      "splash"
      "systemd.show_status=auto"
      "systemd.unified_cgroup_hierarchy=1"
    ];

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
        device = "nodev";
        efiSupport = true;
        default = "saved";
        enable = true;
        useOSProber = true;
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
        zfs rollback -r tank/local/root@blank && echo "rollback complete"
      '';
    };
  };

  services = {
    udev.extraRules = ''
      SUBSYSTEM=="power_supply", KERNEL=="AC", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery.target"
      SUBSYSTEM=="power_supply", KERNEL=="AC", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ac.target"
    '';
    auto-cpufreq.enable = true;
    thermald.enable = true;
    logind = {
      extraConfig = ''
        HandleLidSwitchExternalPower=ignore
        LidSwitchIgnoredInhibited=no
      '';
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
