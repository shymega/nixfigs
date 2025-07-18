# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    acpi
    aria2
    curl
    ddcutil
    encfs
    fido2luks
    fuse
    git
    gnupg
    goimapnotify
    htop
    ifuse
    iw
    libimobiledevice
    lm_sensors
    nano
    neovim
    nvme-cli
    pciutils
    powertop
    rsync
    smartmontools
    solo2-cli
    syncthing
    tmux
    usbutils
    wget
  ];
}
