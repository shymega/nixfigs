# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{pkgs, ...}: {
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
    actionlint.enable = true;
    alejandra.enable = true;
    jsonfmt.enable = true;
    mdformat.enable = true;
    statix.enable = true;
    yamlfmt.enable = true;
  };
}
