# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  goimapnotify = prev.goimapnotify.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        (prev.fetchpatch {
          url = "https://gist.githubusercontent.com/shymega/c6d5701c2d8be448638f59de3842ae33/raw/930d46071c91f2276938505e7d5bb5ea891df850/0001-fix-Disable-Running-commit-messsage.patch";
          sha256 = "sha256-NSjCrjMDT2mpUSeDVFuboowFlMCE9KZYyMj0x/AlY1Y=";
        })
      ];
  });
}
