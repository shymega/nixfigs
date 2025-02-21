# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, ... }: {
  environment.systemPackages = with pkgs.unstable; [
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
    libimobiledeviec
    lm_sensors
    nano
    nvme-cli
    pciutils
    powertop
    ryzenadj
    smartmontools
    solo2-cli
    syncthing
    tmux
    usbutils
    wget
  ];
}
