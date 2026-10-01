# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
_: prev: {
  pmbootstrap-bumped = prev.pmbootstrap.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) src version pname;

    doCheck = false;
    doInstallCheck = false;
  });
}
