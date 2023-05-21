{ pkgs, lib, user, ... }:

{
  imports = [ ./hardware-configuration.nix ./wayland.nix ./x11.nix ];

  networking.hostName = "TRINITY-LINUX";
  time.timeZone = "Europe/London";

  boot = {
    cleanTmpDir = true;

    supportedFilesystems = [ "ntfs" ];
    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';

    kernelPackages = pkgs.linuxPackages_xanmod_latest;

    kernelParams = [ "quiet" "mem_sleep_default=deep" "loglevel=3" "splash" ];

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
      systemd-boot = { enable = true; };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      timeout = 3;
    };

    # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
    initrd.postDeviceCommands = lib.mkBefore ''
      mkdir -p /mnt

      # We first mount the btrfs root to /mnt
      # so we can manipulate btrfs subvolumes.
      mount -o subvol=/ /dev/disk/by-label/NIXOS_BTRFS_ROOT /mnt

      # While we're tempted to just delete /root and create
      # a new snapshot from /root-blank, /root is already
      # populated at this point with a number of subvolumes,
      # which makes `btrfs subvolume delete` fail.
      # So, we remove them first.
      #
      # /root contains subvolumes:
      # - /root/var/lib/portables
      # - /root/var/lib/machines
      #
      # I suspect these are related to systemd-nspawn, but
      # since I don't use it I'm not 100% sure.
      # Anyhow, deleting these subvolumes hasn't resulted
      # in any issues so far, except for fairly
      # benign-looking errors from systemd-tmpfiles.
      btrfs subvolume list -o /mnt/root |
      cut -f9 -d' ' |
      while read subvolume; do
        echo "deleting /$subvolume subvolume..."
        btrfs subvolume delete "/mnt/$subvolume"
      done &&
      echo "deleting /root subvolume..." &&
      btrfs subvolume delete /mnt/root

      echo "restoring blank /root subvolume..."
      btrfs subvolume snapshot /mnt/root-blank /mnt/root

      # Once we're done rolling back to a blank snapshot,
      # we can unmount /mnt and continue on the boot process.
      umount /mnt
    '';
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block start battery.target"
    SUBSYSTEM=="power_supply", KERNEL=="ADP1", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start ac.target"
  '';

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;

  services.logind = {
    extraConfig = ''
      HandleLidSwitchExternalPower=ignore
      LidSwitchIgnoredInhibited=no
    '';
  };
  hardware.opengl = {
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
    driSupport = true;
    driSupport32Bit = true;
  };

  services.udev = {
    packages = with pkgs; [ gnome.gnome-settings-daemon ];
    extraHwdb = ''
      sensor:modalias:*
       ACCEL_MOUNT_MATRIX=-0, -1, 0; -1, 0, 0; 0, 0, 1
    '';
  };

}
