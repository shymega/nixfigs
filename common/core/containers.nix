# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ inputs, outputs, config, ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
}
