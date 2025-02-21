final: prev: {
  offlineimap-shymega = prev.offlineimap.overrideAttrs (finalAttrs: prevAttrs: {
    version = "git";
    src = builtins.fetchGit {
      url = "https://github.com/shymega/OfflineIMAP3";
      ref = "shymega-fixes";
    };
  });
}
