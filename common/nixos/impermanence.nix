# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs }: {
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/usr/local"
      "/var/lib/NetworkManager"
      "/root"
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
    files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
