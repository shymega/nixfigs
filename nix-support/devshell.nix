# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{
  pkgs,
  self,
  system ? "x86_64-linux",
  hostPlatform ? system,
  ...
}: {
  default = pkgs.mkShell {
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
    inherit (self.checks.${hostPlatform}.pre-commit-check) shellHook;
    buildInputs = self.checks.${hostPlatform}.pre-commit-check.enabledPackages;
  };
}
