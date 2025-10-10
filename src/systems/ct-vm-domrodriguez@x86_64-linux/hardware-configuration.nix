# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
# Hardware configuration for ct-vm-domrodriguez libvirt VM
# Optimized for QEMU/KVM virtualization with ZFS backing
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # VM CPU configuration
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "virtio_net"
    "virtio_balloon"
    "virtio_rng"
    "9p"
    "9pnet_virtio"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_rng"
  ];
  boot.kernelModules = ["kvm-amd"]; # Assuming AMD host (DEUSEX-LINUX)
  boot.extraModulePackages = [];

  # Hardware acceleration for VM
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    # Use software rendering for compatibility
    package = pkgs.mesa.drivers;
  };

  # Audio configuration for remote desktop
  sound.enable = false; # Using PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = false; # Not needed for VM
  };

  # Network hardware (virtio)
  networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp1s0.useDHCP = lib.mkDefault true; # Typical virtio interface

  # Power management (minimal for VM)
  powerManagement.enable = false;

  # No firmware updates needed for VM
  services.fwupd.enable = lib.mkForce false;

  # Disable hardware-specific services
  services.thermald.enable = lib.mkForce false;
  services.auto-cpufreq.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;

  # VM memory configuration
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25; # Conservative for VM
  };

  # Graphics driver for VM
  services.xserver.videoDrivers = [
    "virtio"
    "qxl"
  ];

  # VM-specific optimizations
  boot.kernel.sysctl = {
    # Memory optimizations for VM
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 15;
    "vm.dirty_background_ratio" = 5;

    # Network optimizations for virtualized environment
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
