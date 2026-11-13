# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
{
  lib,
  inputs,
  ...
}:
with lib; let
  importStableOverlay = overlay:
    composeExtensions (_: _: {__inputs = inputs;}) (import (./stable/enabled.d + "/${overlay}"));

  stableOverlays = builtins.readDir ./stable/enabled.d;

  stableOverlaysWithImports =
    mapAttrs' (
      overlay: _: nameValuePair (removeSuffix ".nix" overlay) (importStableOverlay overlay)
    )
    stableOverlays;

  defaultOverlays = with inputs; let
    openclawOverlaySafe = final: prev:
    # Only apply when stdenv exists (real nixpkgs, not flake check)
      if prev ? stdenv
      then inputs.nix-openclaw.overlays.default final prev
      else {};
    hyprnixOverlaySafe = _: prev: let
      inherit (prev.stdenv.hostPlatform) system;
      hyprnixPkgs = hyprnix.packages.${system} or {};
      # Only rescan CRTCs on re-enable, not on disable, so a DPMS-off-induced
      # connector flap doesn't force a full CRTC reassignment/modeset. See
      # packages/aquamarine/aquamarine-dpms-crtc-churn.patch.
      #
      # DisplayLink/evdi devices have no render node, so registering them
      # with a primary GPU makes aquamarine try (and fail/time out) to stand
      # up a renderer on them -- the actual cause of the long Hyprland
      # startup stall and black DisplayLink panels, not the atomic-commit
      # path AQ_NO_ATOMIC targets (hyprwm/aquamarine#22). See
      # packages/aquamarine/aquamarine-displaylink-no-render.patch.
      aquamarine = hyprnixPkgs.aquamarine.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ../packages/aquamarine/aquamarine-dpms-crtc-churn.patch
            ../packages/aquamarine/aquamarine-displaylink-no-render.patch
          ];
      });
      # Stock hyprlock aborts (SIGABRT, RASSERT at hyprlock.cpp:412) the
      # instant it sees a POLLHUP on any polled fd -- including its own
      # Wayland connection during a DPMS/monitor-reconnect or suspend/resume
      # cycle (hyprwm/hyprlock#991), which upstream's own SessionLockManager
      # confirms can flash Hyprland's "lockdead" screen. The real fix
      # (hyprwm/hyprlock#1052, unmerged) makes that a graceful, logged exit(1)
      # instead of an abort. hyprlock has no aquamarine dependency, so this
      # just needs the patch, not relinkAquamarine.
      hyprlock = hyprnixPkgs.hyprlock.overrideAttrs (old: {
        patches = (old.patches or []) ++ [../packages/hyprlock/hyprlock-graceful-disconnect.patch];
      });
      # None of these expose aquamarine as an `.override`-able argument, so
      # the patched build has to be swapped in afterwards via overrideAttrs.
      relinkAquamarine = pkg: let
        swap = dep:
          if lib.getName dep == lib.getName aquamarine
          then aquamarine
          else dep;
      in
        pkg.overrideAttrs (old: {
          buildInputs = map swap (old.buildInputs or []);
          propagatedBuildInputs = map swap (old.propagatedBuildInputs or []);
        });
      # hyprnix pins its own nixpkgs (nixos-unstable), which has drifted to
      # glaze 8.x. Hyprland's CMakeLists still find_package()s glaze 7.2.0
      # under CMake's default SameMajorVersion compatibility, so major 8
      # is reported "not found" and the build falls back to a git+network
      # FetchContent that the build sandbox can't perform. This repo's own
      # nixpkgs pin still has a compatible major-7 glaze, so use that.
      glazeHyprland = prev.glaze.override {
        enableSSL = false;
        enableInterop = false;
      };
      hyprland = relinkAquamarine (hyprnixPkgs.hyprland.override {glaze-hyprland = glazeHyprland;});
    in
      if hyprnixPkgs ? aquamarine
      then
        hyprnixPkgs
        // {
          inherit aquamarine hyprland hyprlock;
          hyprland-guiutils = relinkAquamarine hyprnixPkgs.hyprland-guiutils;
          hyprlauncher = relinkAquamarine hyprnixPkgs.hyprlauncher;
          hyprpaper = relinkAquamarine hyprnixPkgs.hyprpaper;
          hyprpolkitagent = relinkAquamarine hyprnixPkgs.hyprpolkitagent;
          hyprpwcenter = relinkAquamarine hyprnixPkgs.hyprpwcenter;
          hyprshutdown = relinkAquamarine (hyprnixPkgs.hyprshutdown.override {glaze = glazeHyprland;});
          hyprtoolkit = relinkAquamarine hyprnixPkgs.hyprtoolkit;
          xdg-desktop-portal-hyprland = relinkAquamarine hyprnixPkgs.xdg-desktop-portal-hyprland;
          # nixpkgs' hyprshot wraps whatever `hyprland` it was called with;
          # point it at the overlay's patched derivation instead.
          hyprshot = prev.hyprshot.override {inherit hyprland;};
        }
      else hyprnixPkgs;
  in [
    agenix.overlays.default
    atuin.overlays.default
    breezy-desktop.overlays.default
    devenv.overlays.default
    dzr-taskwarrior-recur.overlays.default
    hyprnixOverlaySafe
    nix-alien.overlays.default
    nix-cachyos-kernel.overlays.pinned
    nix-doom-emacs-unstraightened.overlays.default
    nur.overlays.default
    openclawOverlaySafe
    shypkgs-public.overlays.default
    sops-nix.overlays.default
    waybar.overlays.default
  ];

  customOverlays = [
    (import ./shymega {inherit inputs lib;})
    (import ./unstable {inherit inputs lib;})
  ];
in {
  # Only expose the composed overlay: every consumer applies overlays via
  # `builtins.attrValues self.overlays`, so also exposing the individual
  # stable overlays here would double-apply each of them (already included
  # in `default`) -- non-idempotent overlays like nix-output-monitor's patch
  # then fail to apply a second time.
  default = composeManyExtensions (
    defaultOverlays ++ customOverlays ++ (attrValues stableOverlaysWithImports)
  );
}
