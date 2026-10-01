# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    acpi
    aria2
    curl
    ddcutil
    dovecot_pigeonhole
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
    nvme-cli
    pciutils
    powertop
    smartmontools
    solo2-cli
    syncthing
    tmux
    usbutils
    wget
  ];
}
