# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  pmbootstrap-bumped = prev.pmbootstrap.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) src version pname;

    doCheck = false;
    doInstallCheck = false;
  });
}
