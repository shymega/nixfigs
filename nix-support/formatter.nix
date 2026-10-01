# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{pkgs, ...}: {
  package = pkgs.treefmt;
  projectRootFile = "flake.nix";

  settings = {
    global.excludes = [
      "*.age"
      "*.md"
      "*.gpg"
      "*.bin"
    ];
    shellcheck.includes = [
      "*"
      ".envrc"
    ];
  };
  programs = {
    deadnix.enable = true;
    statix.enable = true;
    alejandra.enable = true;
    yamlfmt.enable = true;
    jsonfmt.enable = true;
    mdformat.enable = true;
    actionlint.enable = true;
  };
}
