final: prev: {
  nix-output-monitor = prev.nix-output-monitor.override {
    extraComposeFunctions = [
      (prev.haskell.lib.compose.appendPatch (
        prev.fetchpatch2 {
          url = "https://patch-diff.githubusercontent.com/raw/maralorn/nix-output-monitor/pull/321.patch";
          relative = "nix-output-monitor";
          hash = "sha256-uleti4hBzGN/uQS7CxUi4FaVs+fy+Q/rmqDPNPXBNiM=";
        }
      ))
    ];
  };

  nh = prev.nh.override {
    inherit (final) nix-output-monitor;
  };
}
