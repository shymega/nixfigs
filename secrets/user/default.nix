# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{
  age = {
    identityPaths = [ "/home/dzrodriguez/.ssh/id_ed25519" ];
    secrets = {
      atuin_key.file = ./atuin_key.age;
      nix_conf_access_tokens.file = ./nix_conf_access_tokens.age;
    };
  };
}
