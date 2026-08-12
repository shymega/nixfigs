# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
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
