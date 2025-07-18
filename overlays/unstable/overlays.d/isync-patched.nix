# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  isync-patched = prev.isync.overrideAttrs (
    oldAttrs: {
      inherit (oldAttrs) autoreconfPhase;
      version = "1.5.1";
      src = prev.fetchgit {
        url = "https://git.code.sf.net/p/isync/isync";
        tag = "v1.5.1";
        hash = "sha256-l0jL4CzAdFtQGekbywic1Kuihy3ZQi4ozhSEcbJI0t0=";
      };
      withCyrusSaslXoauth2 = true;
    }
  );
}
