# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs
, self
, system
, ...
}:
{
  default = pkgs.mkShell {
    name = "nix-config";

    nativeBuildInputs = with pkgs; [
      act
      actionlint
      agenix
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
    inherit (self.checks.${system}.pre-commit-check) shellHook;
    buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
  };
}
