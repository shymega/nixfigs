# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  system,
  inputs,
  lib,
  self,
  ...
}: let
  genPkgs = system:
    import inputs.nixpkgs {
      inherit system;
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
    pkgs = genPkgs system;
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
    inputs.git-hooks.lib.${system}.run {
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
