# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  pidgin,
  glib,
  json-glib,
  sqlite,
  olm,
  libgcrypt,
  http-parser,
}:
stdenv.mkDerivation {
  pname = "purple-matrix";
  version = "unstable-2023-04-24";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "purple-matrix";
    rev = "2792d4db0916ad821886de1f8de3a5e46c66ca37";
    hash = "sha256-+j6jfa3oN17xna1w5nyelLYG6X8vR/HUU9pjAap/QHI=";
  };

  # Upstream's Makefile.common hardcodes `-O0 -Werror`, which turns glibc's
  # "_FORTIFY_SOURCE requires compiling with optimization" warning (triggered
  # by nixpkgs' default hardening flags at -O0) into a build failure.
  hardeningDisable = ["fortify"];

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    pidgin
    glib
    json-glib
    sqlite
    olm
    libgcrypt
    http-parser
  ];

  PKG_CONFIG_PURPLE_PLUGINDIR = "${placeholder "out"}/lib/purple-2";
  PKG_CONFIG_PURPLE_DATAROOTDIR = "${placeholder "out"}/share";

  meta = {
    description = "Libpurple protocol plugin for Matrix";
    homepage = "https://github.com/matrix-org/purple-matrix";
    license = lib.licenses.gpl2Plus;
    maintainers = [];
    platforms = lib.platforms.linux;
  };
}
