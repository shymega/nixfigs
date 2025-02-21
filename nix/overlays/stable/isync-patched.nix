# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

final: prev: {
  isync-patched = final.symlinkJoin {
    name = "isync-patched";
    version = "1.5";
    src = builtins.fetchGit {
      url = "https://github.com/shymega/isync.git";
      ref = "wip/exchange-workarounds-1.5";
      rev = "1e89fac089ec423fc1e99884b752f9f20fc8fda2";
    };

    patches = [ ];
    paths = [
      (prev.writeShellScriptBin "mbsync" ''
        export SASL_PATH=${prev.cyrus_sasl.out}/lib/sasl2:${prev.cyrus-sasl-xoauth2}/lib/sasl2
        exec ${prev.isync}/bin/mbsync "$@"
      '')
      prev.isync
    ];
  };
}

