# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  ...
}: {
  imports = [./disks.nix];

  boot.initrd.availableKernelModules = ["nvme" "thunderbolt" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "amdgpu" "hid_apple"];
  boot.initrd.kernelModules = ["amdgpu" "hid-apple"];
  boot.kernelModules = ["kvm-amd" "amdgpu"];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
