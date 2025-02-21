# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

final: prev: {
  isync-patched = prev.isync.overrideAttrs (oldAttrs: rec {
    pname = "isync";
    version = "1.5.0";
    src = prev.fetchurl {
      url = "mirror://sourceforge/isync/${pname}-${version}.tar.gz";
      sha256 = "sha256-oMgeEJOHvyedoWFFMQM5nneUav7PXFH5QTxedzVX940=";
    };
    withCyrusSaslXoauth2 = true;
    dontPatch = true;
  });
}

