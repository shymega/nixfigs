# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/home/dzrodriguez/.ssh/id_ed25519"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      postfix_sasl_passwd.file = ./postfix_sasl_passwd.age;
      postfix_sender_relay.file = ./postfix_sender_relay.age;
      user_dzrodriguez.file = ./user_dzrodriguez.age;
      atuin_key.file = ./atuin_key.age;
      geoclue_url.file = ./geoclue_url.age;
    };
  };
}
