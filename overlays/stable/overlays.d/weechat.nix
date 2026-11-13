# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
_final: prev: {
  # shymega/add-ircv3-CHATHISTORY branch
  weechatWithChathistory = prev.wrapWeechat (prev.weechat-unwrapped.overrideAttrs (_oldAttrs: {
    version = "unstable";
    doInstallCheck = false;

    src = prev.fetchFromGitHub {
      owner = "shymega";
      repo = "weechat";
      rev = "df5ef9d153a0a6940e4ede76d543db0cf23e5edc";
      hash = "sha256-XolKV3DcKUajJM0/D6sE14CimsXRoxr/H1gZ6X6Mozo=";
    };
  })) {};
}
