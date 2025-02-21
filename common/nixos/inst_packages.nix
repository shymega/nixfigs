# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ pkgs, ... }:
{
  environment.systemPackages =
    with pkgs.unstable;
    [
      acpi
      curl
      encfs
      fido2luks
      fuse
      git
      gnupg
      htop
      ifuse
      iw
      libimobiledevice
      lm_sensors
      nano
      nvme-cli
      pciutils
      powertop
      smartmontools
      solo2-cli
      syncthing
      tmux
      usbutils
      wget
    ] ++ (with pkgs.shymega; [
      net-type
    ]);
}
