# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      postfix_sasl_passwd.file = ./system/postfix_sasl_passwd.age;
      postfix_sender_relay.file = ./system/postfix_sender_relay.age;
      user_dzrodriguez.file = ./system/user_dzrodriguez.age;
      geoclue_url.file = ./system/geoclue_url.age;
    };
  };
}
