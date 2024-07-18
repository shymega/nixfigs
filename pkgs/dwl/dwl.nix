final: prev: {
  dwl = pkgs.dwl.overrideAttrs
    (finalAttrs: {
      src = inputs.dwl-source;
      patches = [
        ./pkgs/dwl/dwl-patches/attachbottom.patch
        ./pkgs/dwl/dwl-patches/autostart.patch
        ./pkgs/dwl/dwl-patches/focusdirection.patch
        ./pkgs/dwl/dwl-patches/monfig.patch
        ./pkgs/dwl/dwl-patches/point.patch
        ./pkgs/dwl/dwl-patches/restoreTiling.patch
        ./pkgs/dwl/dwl-patches/save_monitor_state.patch
        ./pkgs/dwl/dwl-patches/steam_fix.patch
        ./pkgs/dwl/dwl-patches/toggleKbLayout.patch
        ./pkgs/dwl/dwl-patches/vanitygaps.patch
      ];
    });
}
