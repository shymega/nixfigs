# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  self,
  hostPlatform,
  inputs,
  pkgs ? inputs.nixpkgs.legacyPackages.${hostPlatform},
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
          age
          deploy-rs
          git-crypt
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
          sops
          ssh-to-age
          statix
        ];

        inherit (self.checks.${hostPlatform}.pre-commit-check) shellHook;
        buildInputs = self.checks.${hostPlatform}.pre-commit-check.enabledPackages;
      }
