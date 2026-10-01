# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{lib, ...}: {
  boot = {
    initrd.availableKernelModules = lib.mkForce [
      "usbhid"
      "usb_storage"
      "vc4"
      "pcie_brcmstb" # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
      "hid_apple"
    ];

    kernelParams = lib.mkAfter [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      "cma=128M"
      "kunit.enable=0"
      "sdhci.debug_quirks2=4"
    ];
  };
}
