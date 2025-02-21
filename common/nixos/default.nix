# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ ... }: {
  imports = [
    ./bluetooth.nix
    ./custom-systemd-units
    ./dovecot2.nix
    ./fido2.nix
    ./firmware.nix
    ./impermanence.nix
    ./inst_packages.nix
    ./kernel_params.nix
    ./keychron.nix
    ./networking.nix
    ./pam.nix
    ./postfix.nix
    ./sound.nix
    ./steam-hardware.nix
    ./systemd-initrd.nix
    ./wayland.nix
    ./x11.nix
    ./xdg.nix
  ];
}
