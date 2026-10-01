# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{lib, ...}: {
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  boot = {
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
      "cma=128M"
      "kunit.enable=0"
    ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = ["noatime"];
  };
}
