# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
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
