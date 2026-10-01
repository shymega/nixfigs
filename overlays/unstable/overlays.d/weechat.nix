# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
_: prev: {
  weechatWithMyPlugins = prev.weechat.override {
    configure = {availablePlugins, ...}: {
      scripts = let
        weechat-matrix = prev.weechatScripts.weechat-matrix.overrideAttrs (oldAttrs: {
          patches =
            oldAttrs.patches or []
            ++ [
              (prev.fetchpatch {
                url = "https://patch-diff.githubusercontent.com/raw/poljar/weechat-matrix/pull/349.diff?full_index=1";
                hash = "sha256-oJ+vfdSWhEWdKG52c9kiOXCeOscq+sSL3N8CoI7OiZo=";
              })
            ];
        });
      in
        with prev.weechatScripts;
          [
            autosort
            edit
            url_hint
            wee-slack
            weechat-autosort
            weechat-go
            weechat-notify-send
            zncplayback
          ]
          ++ [weechat-matrix];
      plugins = builtins.attrValues availablePlugins;
    };
  };
}
