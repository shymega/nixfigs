# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

_final: prev: {
  isync-patched = prev.isync.overrideAttrs (_oldAttrs: rec {
    pname = "isync";
    version = "1.5.0";
    src = prev.fetchgit {
      url = "https://git.code.sf.net/p/isync/isync";
      rev = "0af93316ff2d62472e3faa23420180910b32d858";
      sha256 = "sha256-yqe+qiZLletTuVD9pQKDX57wCBh2LoOr2QBJFBNnhNE=";
    };
    withCyrusSaslXoauth2 = true;
    dontPatch = true;

    preConfigure = ''
      touch ChangeLog
      ./autogen.sh
    '';

    nativeBuildInputs = with prev; [ autoconf automake perl pkg-config ];
    buildInputs = with prev; [ cyrus_sasl db openssl zlib wrapProgram ];
  });
}
