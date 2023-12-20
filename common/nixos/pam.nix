# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ ... }: {
  security.pam.services = {
    gdm.enableKwallet = true;
    lightdm.enableKwallet = true;
    sddm.enableKwallet = true;
    "dzrodriguez".enableKwallet = true;
  };
}
