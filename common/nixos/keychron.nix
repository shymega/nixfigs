# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
}
