# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  age = {
    identityPaths = [
      "/home/dzrodriguez/.ssh/id_ed25519"
    ];
    secrets = {
      atuin_key.file = ../secrets/user/atuin_key.age;
    };
  };
}
