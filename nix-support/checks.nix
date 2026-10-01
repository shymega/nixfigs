# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{
  system ? "x86_64-linux",
  hostPlatform ? system,
  inputs,
  lib,
  self,
  ...
}:
inputs.git-hooks.lib.${hostPlatform}.run {
  src = lib.cleanSource "${self}/.";
  hooks = {
    deadnix.enable = true;
    alejandra.enable = true;
    yamlfmt.enable = true;
    actionlint.enable = true;
    statix = {
      enable = false;
      settings.ignore = [
        "flake.nix"
        "*-compose.nix"
        "mautrix-whatsapp.nix"
        "mautrix-slack.nix"
        ".devenv"
        ".direnv"
      ];
    };
  };
}
