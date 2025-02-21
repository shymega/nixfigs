# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, lib, config, ... }: {
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
      "/opt"
      "/root"
      "/usr/local"
      "/var/lib/NetworkManager"
    ] ++ lib.optionals (config.networking.hostName == "NEO-LINUX") [
      "/var/lib/bluetooth"
      "/var/lib/cni"
      "/var/lib/containers"
      "/var/lib/docker"
      "/var/lib/flatpak"
      "/var/lib/libvirt"
      "/var/lib/lxc"
      "/var/lib/lxd"
      "/var/lib/machines"
      "/var/lib/nixos"
      "/var/lib/postfix"
      "/var/lib/wayland"
      "/var/lib/zerotier-one"
    ];
  };
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
