# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  system,
  inputs,
  lib ? inputs.nixpkgs.lib,
  self,
  ...
}: let
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
    genPkgs = system:
      import inputs.nixpkgs {
        inherit system;
      };
    pkgs = genPkgs system;
  in
    pkgs.writeShellScriptBin "dummy-check" ''
      exit 0
    '';
in
  if isUnsupportedSystem
  then dummyCheck
  else
    inputs.git-hooks.lib.${system}.run {
      src = lib.cleanSource "${self}/.";

      # Enhanced pre-commit hooks
      hooks = {
        # Nix
        nixfmt.enable = true;
        statix = {
          enable = true;
          settings.ignore = [
            "flake.nix"
            "*-compose.nix"
            "mautrix-whatsapp.nix"
            "mautrix-slack.nix"
            ".devenv"
            ".direnv"
          ];
        };
        deadnix.enable = true;

        # Shell scripts
        shellcheck.enable = true;
        shfmt.enable = true;

        # YAML/JSON
        yamlfmt.enable = true;
        check-yaml.enable = true;
        check-json.enable = true;

        # Markdown
        markdownlint.enable = true;

        # GitHub Actions
        actionlint.enable = true;

        # General
        check-added-large-files.enable = true;
        check-case-conflicts.enable = true;
        check-executables-have-shebangs.enable = true;
        check-merge-conflicts.enable = true;
        check-symlinks.enable = true;
        detect-private-keys.enable = true;
        end-of-file-fixer.enable = true;
        trailing-whitespace.enable = true;
      };
    }
