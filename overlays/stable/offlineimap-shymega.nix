# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

final: prev: {
  offlineimap-shymega = prev.offlineimap.overrideAttrs {
    version = "git";
    src = builtins.fetchGit {
      url = "https://github.com/shymega/OfflineIMAP3";
      ref = "shymega-fixes";
      rev = "a7c311c0ec44bd64cf666d9ef187fec87b72b5b7";
    };
  };
}
