# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ config, lib, ... }:
{ boot.initrd.systemd.enable = lib.mkForce true; }
