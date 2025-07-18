# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  inputs,
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) checkRoles;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/nixos/vm # VM-specific modules
  ];

  # System identification
  networking.hostName = "ct-vm-domrodriguez";
  networking.hostId = "87654321"; # Generate unique ID: head -c4 /dev/urandom | od -A none -t x4

  # Boot configuration for VM
  boot = {
    loader = {
      grub = {
        enable = lib.mkForce true;
        device = "/dev/vda"; # Standard libvirt disk
      };
    };

    # VM-optimized kernel parameters
    kernelParams = [
      "quiet"
      "splash"
      "systemd.show_status=auto"
      "rd.udev.log_priority=3"
    ];

    # Enable required kernel modules for VM
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_scsi"
      "virtio_net"
      "virtio_blk"
      "virtio_balloon"
      "virtio_rng"
    ];

    # VM doesn't need initrd secrets
    initrd.systemd.enable = true;
  };

  # ZFS configuration for VM (backed by host ZFS dataset)
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    forceImportRoot = false;
    allowHibernation = false; # VMs typically don't hibernate
  };

  # File systems for VM
  fileSystems = {
    "/" = {
      device = "vmpool/ct-vm-domrodriguez/root";
      fsType = "zfs";
      options = [
        "zfsutil"
        "noatime"
      ];
    };

    "/home" = {
      device = "vmpool/ct-vm-domrodriguez/home";
      fsType = "zfs";
      options = [
        "zfsutil"
        "noatime"
      ];
    };

    "/nix" = {
      device = "vmpool/ct-vm-domrodriguez/nix";
      fsType = "zfs";
      options = [
        "zfsutil"
        "noatime"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "ext4";
    };
  };

  # No swap needed for VM (host manages memory)
  swapDevices = [ ];

  # VM user configuration
  users.users.domrodriguez = {
    isNormalUser = true;
    description = "Dom Rodriguez (VM User)";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "render" # For graphics acceleration
    ];
    # Password will be set via SOPS
    hashedPasswordFile = "/run/secrets/domrodriguez-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderVMUserSSHKey" # Replace with actual key
    ];

    # Auto-login shell for remote access
    shell = pkgs.zsh;
  };

  # Disable root login
  users.users.root.hashedPassword = "!";

  # VM environment packages
  environment.systemPackages = with pkgs; [
    # Essential VM tools
    qemu-utils
    libguestfs

    # System monitoring
    htop
    iotop

    # Network tools
    nettools
    iproute2
    dnsutils

    # Development tools
    git
    vim
    curl
    wget

    # ZFS tools
    zfs
    zfsutils-linux
  ];

  # VM-specific services
  services = {
    # Disable unnecessary services for VM
    thermald.enable = lib.mkForce false;

    # Enable essential VM services
    qemuGuest.enable = true;
    openssh.enable = true;

    # ZFS services
    zfs = {
      autoScrub.enable = false; # Host handles scrubbing
      autoSnapshot.enable = true; # VM-level snapshots
      autoSnapshot.frequent = 8; # Every 15 minutes
      autoSnapshot.hourly = 24;
      autoSnapshot.daily = 7;
      autoSnapshot.weekly = 4;
      autoSnapshot.monthly = 12;
    };
  };

  # VM hardware configuration
  hardware = {
    # Audio for remote desktop
    pulseaudio.enable = false; # Using PipeWire instead

    # Graphics for VM
    opengl = {
      enable = true;
      driSupport = true;
    };
  };

  # Network configuration
  systemd.network = {
    enable = false; # Using NetworkManager
  };

  # Time zone (inherit from host)
  time.timeZone = "Europe/London"; # Adjust as needed

  # Locale settings
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # ZSH configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # VM security settings
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };

    # VM-appropriate AppArmor settings
    apparmor.enable = true;
  };

  # System state version
  system.stateVersion = "25.05";
}
