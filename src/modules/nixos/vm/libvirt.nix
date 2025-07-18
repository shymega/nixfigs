# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:
let
  inherit (config.nixfigs.roles) checkRoles;
  isLibvirtVM = checkRoles ["virtual-machine" "libvirt"] config;
in {
  config = lib.mkIf isLibvirtVM {
    # VM-specific optimizations
    boot = {
      # Faster boot for VMs
      initrd.systemd.enable = true;
      kernelParams = [
        "quiet"
        "udev.log_priority=3"
        "systemd.show_status=auto"
        "rd.udev.log_priority=3"
      ];
      
      # Reduce boot time
      loader.timeout = 1;
    };

    # VM guest services
    services = {
      # QEMU guest agent for libvirt management
      qemuGuest.enable = true;
      
      # SPICE guest agent for clipboard/display management
      spice-vdagentd.enable = true;
      
      # Auto-resize display to match window
      spice-autorandr.enable = true;
    };

    # VM hardware optimizations
    hardware = {
      # Enable virtio drivers
      enableAllFirmware = false; # VMs don't need firmware
      
      # Graphics optimization for VMs
      opengl = {
        enable = true;
        driSupport = true;
        # Use software rendering in VMs for compatibility
        package = pkgs.mesa.drivers;
      };
    };

    # Network optimization for VMs
    networking = {
      # Use predictable interface names
      usePredictableInterfaceNames = true;
      
      # Optimize for virtualized networking
      dhcpcd.enable = false;
      networkmanager.enable = true;
    };

    # System optimizations for VMs
    environment.systemPackages = with pkgs; [
      # VM management tools
      qemu-utils
      virtiofsd
    ];

    # Disable unnecessary services for VMs
    services = {
      # No power management in VMs
      thermald.enable = lib.mkForce false;
      auto-cpufreq.enable = lib.mkForce false;
      
      # No firmware updates in VMs
      fwupd.enable = lib.mkForce false;
      
      # Disable bluetooth in VMs
      blueman.enable = lib.mkForce false;
    };

    # VM filesystem optimizations
    fileSystems = {
      "/" = {
        options = [ "noatime" "compress=zstd" ]; # Optimize for VM storage
      };
    };

    # Memory optimization
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25; # Conservative for VMs
    };
  };
}