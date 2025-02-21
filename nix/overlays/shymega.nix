{ inputs, lib, ... }:
final: prev: {
  shymega = import inputs.nixpkgs-shymega {
    inherit (prev) system;
    config = {
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
    overlays =
      let
        importShymegaOverlay = overlay:
          lib.composeExtensions
            (_: _: { __inputs = inputs; })
            (import (./shymega + "/${overlay}"));

        shymegaOverlays =
          lib.mapAttrs'
            (overlay: _: lib.nameValuePair
              (lib.removeSuffix ".nix" overlay)
              (importShymegaOverlay overlay))
            (builtins.readDir ./shymega);
      in
      lib.attrValues shymegaOverlays;
  };
}
