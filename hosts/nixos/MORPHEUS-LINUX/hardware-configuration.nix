# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, ... }:
{
  imports = [ ./disks.nix ];
  boot = {
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "sdhci_pci" "hid_apple" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" "i2c_dev" ];
    extraModulePackages = [ ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
