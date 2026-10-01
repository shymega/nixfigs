# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{
  config,
  pkgs,
  ...
}: {
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
      ${pkgs.lib.getExe pkgs.gnused} -i "s#@secret@#$secret#" $conf
    '';
  };
}
