# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

final: prev: {
  isync-xoauth2 = prev.symlinkJoin {
    name = "isync";
    paths = [
      (prev.writeShellScriptBin "mbsync" ''
        export SASL_PATH=${prev.cyrus_sasl.out}/lib/sasl2:${prev.cyrus-sasl-xoauth2}/lib/sasl2
        exec ${prev.isync}/bin/mbsync "$@"
      '')
      prev.isync
    ];
  };
}
