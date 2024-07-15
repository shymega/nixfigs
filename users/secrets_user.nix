# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key"
      "/home/dzr/.ssh/id_ed25519"
    ];
    secrets = {
      atuin_key.file = ../secrets/atuin_key.age;
    };
  };
}
