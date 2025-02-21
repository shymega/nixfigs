# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:
{
  system.activationScripts = {
    "zerotier-networks-secret".text = ''
      secret="${config.age.secrets.zerotier_networks.path}"
      while read -r network; do
        mkdir -p /var/lib/zerotier-one/networks.d
        touch /var/lib/zerotier-one/networks.d/$network.conf
        rm -f /var/lib/zerotier-one/networks.d/@secret@.conf || exit 0l
      done < "$secret"
    '';

    "geoclue.submission-url-secret".text = ''
      secret="$(cat ${config.age.secrets.geoclue_url.path})"
      conf="/etc/geoclue/geoclue.conf"
      ${pkgs.gnused}/bin/sed -i "s#@secret@#$secret#" $conf
    '';
  };
}
