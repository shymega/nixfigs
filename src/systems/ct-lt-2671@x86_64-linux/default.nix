# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, self, config, lib, pkgs, hostRoles, ... }:
let
  inherit (lib) checkRoles;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
    ../../modules/nixos/work # Work-specific modules
  ];

  # System identification
  networking.hostName = "ct-lt-2671";
  networking.hostId = "12345678"; # Generate unique ID: head -c4 /dev/urandom | od -A none -t x4

  # Boot configuration for corporate compliance
  boot = {
    loader = {
      systemd-boot.enable = false; # Disabled for Lanzaboote secure boot
      efi.canTouchEfiVariables = true;
    };
    
    # Secure boot with Lanzaboote
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    
    # Disk encryption (configure based on actual setup)
    initrd = {
      systemd.enable = true;
      luks.devices."luks-root" = {
        device = "/dev/disk/by-uuid/placeholder-luks-uuid"; # Replace with actual UUID
        preLVM = true;
        allowDiscards = true;
      };
    };
    
    # Kernel hardening for work environment
    kernelParams = [
      "lockdown=confidentiality"
      "audit=1"
      "slub_debug=FZP"
      "init_on_alloc=1"
      "init_on_free=1"
    ];
  };

  # File systems (adjust based on actual disk layout)
  fileSystems = {
    "/" = {
      device = "/dev/mapper/luks-root";
      fsType = "ext4";
      options = [ "defaults" "noatime" ];
    };
    
    "/boot" = {
      device = "/dev/disk/by-uuid/placeholder-boot-uuid"; # Replace with actual UUID
      fsType = "vfat";
    };
  };

  # Swap configuration
  swapDevices = [{
    device = "/dev/mapper/luks-swap";
    encrypted = {
      enable = true;
      label = "luks-swap";
      blkDev = "/dev/disk/by-uuid/placeholder-swap-uuid"; # Replace with actual UUID
    };
  }];

  # Work-specific user configuration
  users.users.workuser = {
    isNormalUser = true;
    description = "Work User";
    extraGroups = [ "wheel" "networkmanager" ];
    hashedPassword = "$6$placeholder"; # Replace with actual hashed password
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderWorkUserSSHKey" # Replace with actual key
    ];
  };

  # Disable root login for security
  users.users.root.hashedPassword = "!";

  # Work environment packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    git
    vim
    curl
    wget
    htop
    
    # Security tools
    gnupg
    age
    sops
  ];

  # System state version
  system.stateVersion = "25.05";
}
