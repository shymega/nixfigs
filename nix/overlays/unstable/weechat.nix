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
