# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  nix-output-monitor = prev.nix-output-monitor.overrideAttrs (_: rec {
    version = "2.1.5";

    src = prev.fetchFromGitHub {
      owner = "maralorn";
      repo = "nix-output-monitor";
      rev = "refs/tags/v${version}";
      hash = "sha256-bTmWlcCobvNb+tpHxYYDiLF5vay9UV+bujYqcrpoOgc=";
    };
  });
}
