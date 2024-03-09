# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    acpi
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
    nix-alien
    nvme-cli
    pciutils
    powertop
    protonvpn-cli
    protonvpn-gui
    smartmontools
    solo2-cli
    tmux
    usbutils
    wget
  ];
  programs = {
    nix-ld.enable = true;
  };
}
