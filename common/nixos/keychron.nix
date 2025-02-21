# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0

{ config, ... }: {
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
}
