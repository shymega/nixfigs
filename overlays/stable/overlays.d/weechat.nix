# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  weechat = prev.weechat.overrideAttrs (_: {
    version = "4.10.0-dev";
    src = prev.fetchFromGitHub {
      owner = "shymega";
      repo = "weechat";
      rev = "cdcdfd7522d0aa723d05447068cbd36a49f6d064";
      hash = "sha256-XNTuyQRH01NDW/lAQsf3gIrGDMhTP9NLL0r5gIO93Qw=";
    };
  });
}
