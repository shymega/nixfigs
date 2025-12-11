# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  hostPlatform,
  inputs,
  lib,
  self,
  ...
}: let
  genPkgs = system:
    import inputs.nixpkgs {
      inherit hostPlatform;
    };
  isUnsupportedSystem = let
    unsupportedSystems = [
      "armv6l-linux"
      "armv7l-linux"
      "riscv64-linux"
    ];
    inherit (builtins) any;
  in
    any (x: x == system) unsupportedSystems;
  dummyCheck = let
    pkgs = genPkgs hostPlatform;
  in
    with pkgs;
      writeShellScriptBin "dummy-check"
      ''
        exit 0
      '';
in
  if isUnsupportedSystem
  then dummyCheck
  else
    inputs.git-hooks.lib.${hostPlatform}.run {
      src = lib.cleanSource "${self}/.";
      hooks = {
        actionlint.enable = true;
        alejandra.enable = true;
        yamlfmt.enable = true;
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
