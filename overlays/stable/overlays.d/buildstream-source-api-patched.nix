# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  buildstream-source-api-patched = prev.buildstream.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) version pname src;

    patches =
      (oldAttrs.patches or [])
      ++ [
        (prev.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/apache/buildstream/pull/1997.patch";
          hash = "sha256-ALcbKEDI2fVna4zCs+OUitc6XUHzTNscMxTKxFVG8Ws=";
        })
      ];
  });
}
