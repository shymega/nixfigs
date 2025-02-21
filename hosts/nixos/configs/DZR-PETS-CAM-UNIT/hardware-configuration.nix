# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, lib, ... }:
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi0;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    initrd.availableKernelModules = lib.mkForce [
      "usbhid"
      "usb_storage"
      "xhci_pci"
      "mmc_block"
    ];

    kernelParams = lib.mkAfter [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
    ];

    swraid.enable = lib.mkForce false;
  };
}
