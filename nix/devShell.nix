# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  pkgs,
  self,
  hostPlatform,
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
in
  with pkgs;
    if isUnsupportedSystem
    then
      mkShell {
        name = "nix-config";
      }
    else
      mkShell {
        name = "nix-config";

        nativeBuildInputs = with pkgs; [
          act
          actionlint
          deploy-rs
          jq
          nil
          nix-melt
          nix-output-monitor
          nix-tree
          nixpkgs-fmt
          pre-commit
          python3Packages.pyflakes
          rage
          shellcheck
          shfmt
          statix
        ];

        shellHook = self.checks.${hostPlatform}.pre-commit-check.shellHook;
        buildInputs = self.checks.${hostPlatform}.pre-commit-check.enabledPackages;
      }
