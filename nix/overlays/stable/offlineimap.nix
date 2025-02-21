# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

final: prev: {
  offlineimap = prev.offlineimap.overrideAttrs {
    version = "git";
    src = builtins.fetchGit {
      url = "https://github.com/shymega/OfflineIMAP";
      ref = "shymega-fixes";
      rev = "9e5cdba6e75f6c69c41b8d9880bd7defc74708a4";
    };
  };
}
