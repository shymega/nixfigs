# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
{lib, ...}:
with lib; {
  config = mkIf false {
    services.pantalaimon-headless.instances.rnetMatrix = {
      homeserver = "https://matrix.rodriguez.org.uk";
      listenAddress = "127.0.0.1";
      listenPort = 8008;
    };
  };
}
