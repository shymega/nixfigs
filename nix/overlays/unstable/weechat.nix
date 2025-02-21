# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

final: prev: {
  weechatWithMyPlugins = prev.weechat.override {
    configure = { availablePlugins, ... }: {
      scripts = with prev.pkgs.weechatScripts; [
        buffer_autoset
        colorize_nicks
        url_hint
        weechat-autosort
        weechat-go
        weechat-notify-send
        zncplayback
        wee-slack
        weechat-matrix
      ];
      plugins = builtins.attrValues availablePlugins;
    };
  };
}
