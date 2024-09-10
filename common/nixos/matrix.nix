# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{
  services.pantalaimon-headless.instances.rnetMatrix = {
    homeserver = "https://matrix.rodriguez.org.uk";
    listenAddress = "127.0.0.1";
    listenPort = 8008;
  };
}
