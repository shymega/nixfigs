# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  age = {
    identityPaths = [
      "/home/dominic.rodriguez/.ssh/id_ed25519"
      "/home/dzrodriguez/.ssh/id_ed25519"
    ];
    secrets = {
      atuin_key.file = ./atuin_key.age;
    };
  };
}
