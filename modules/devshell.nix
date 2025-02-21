# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, inputs, ... }:
with pkgs; {
  default = mkShell {
    name = "nix-config";

    nativeBuildInputs = [
      # Nix
      inputs.agenix.packages.${pkgs.system}.agenix
      inputs.deploy-rs.packages.${pkgs.system}.deploy-rs
      nixpkgs-fmt
      cachix
      statix

      # Shell
      shellcheck
      shfmt

      # GitHub Actions
      act
      actionlint

      # Misc
      jq
      pre-commit
    ];
  };
}
