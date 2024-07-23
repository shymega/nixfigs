# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
    acpi
    ryzenadj
    curl
    encfs
    fido2luks
    fuse
    git
    gnupg
    htop
    iw
    lm_sensors
    nano
    nvme-cli
    pciutils
    powertop
    smartmontools
    solo2-cli
    tmux
    syncthing
    usbutils
    wget
  ];
}
