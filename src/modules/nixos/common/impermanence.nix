# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  lib,
  config,
  inputs,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  environment.persistence."/persist" = {
    hideMounts = false;
    files = ["/etc/machine-id"];
    directories =
      [
        "/etc/NetworkManager/system-connections"
        "/etc/secureboot"
        "/opt"
        "/root"
        "/usr/local"
      ]
      ++ lib.optionals (lib.hasSuffix "-LINUX" config.networking.hostName) [
        "/var/spool/atjobs"
        "/var/spool/atspool"
        "/var/spool/leafnode"
        "/var/spool/mail"
      ]
      ++ lib.optionals
      (config.networking.hostName == "NEO-LINUX" || config.networking.hostName == "TWINS-LINUX")
      [
        "/var/lib/AccountsService"
        "/var/lib/alsa"
        "/var/lib/bluetooth"
        "/var/lib/cni"
        "/var/lib/containers"
        "/var/lib/davmail"
        "/var/lib/docker"
        "/var/lib/flatpak"
        "/var/lib/geoclue"
        "/var/lib/libvirt"
        "/var/lib/lxc"
        "/var/lib/lxd"
        "/var/lib/machines"
        "/var/lib/NetworkManager"
        "/var/lib/nixos"
        "/var/lib/ollama -> private/ollama"
        "/var/lib/os-prober"
        "/var/lib/postfix"
        "/var/lib/power-profiles-daemon"
        "/var/lib/private"
        "/var/lib/systemd"
        "/var/lib/upower"
        "/var/lib/wayland"
        "/var/lib/zerotier-one"
      ]
      ++ lib.optional (config.networking.hostName == "delta-zero") "/var/lib/davmail";
  };
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
