# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  enabled = checkRoles ["workstation"] config.nixfigs.meta.rolesEnabled;
  sway-wrapped-hw = pkgs.writeShellScript "sway-wrapped-hw" ''
    #!/bin/sh
    export WLR_NO_HARDWARE_CURSORS=1
    exec ${getExe pkgs.sway} --unsupported-gpu "$@"
  '';
in {
  config = mkIf enabled {
    environment.etc."greetd/kanshi-config" = {
      source = "${config.users.users."dzrodriguez".home}/.config/kanshi/config";
      uid = 0;
      gid = 0;
      mode = "777";
    };

    services = {
      displayManager.defaultSession = "sway";
      xserver = {
        enable = true;
        displayManager = {
          startx.enable = true;
          gdm = {
            enable = false;
            autoSuspend = false;
          };
        };
        desktopManager = {
          gnome.enable = true;
        };
        xkb.layout = "us";
      };
      desktopManager = {
        plasma6.enable = true;
      };
      libinput.enable = true;
      greetd = {
        enable = true;
        settings = {
          default_session = let
            hyprConfig = pkgs.writeText "greetd-hyprland-config" ''
              exec-once=${getExe pkgs.kanshi} -c /etc/greetd/kanshi-config
              exec-once=${getExe pkgs.greetd.regreet}; hyprctl dispatch exit
              debug {
                disable_scale_checks = true
              }

              misc {
                disable_hyprland_logo = true
                disable_splash_rendering = true
              }
              env = GTK_USE_PORTAL,0
              env = GDK_DEBUG,no-portals
              env = AQ_NO_MODIFIERS,1
              env = GDK_BACKEND,wayland
              env = GDK_SCALE,2
              env = MOZ_ENABLE_WAYLAND,1
              env = QT_AUTO_SCREEN_SCALE_FACTOR,1
              env = QT_QPA_PLATFORM,wayland;xcb
              env = QT_ENABLE_HIGHDPI_SCALING,1
              env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
              env = SDL_VIDEODRIVER,wayland
              env = XDG_SESSION_TYPE,wayland
              env = _JAVA_AWT_WM_NONREPARENTING,1
              cursor {
                no_hardware_cursors = 1
              }
            '';
          in {
            command = "${getExe pkgs.hyprland} --config ${hyprConfig}";
            user = "greeter";
          };
        };
      };
    };
    environment.etc."greetd/environments".text = ''
      ${getExe pkgs.hyprland}
      ${sway-wrapped-hw}
      ${getExe pkgs.dwl}
      ${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland
      ${pkgs.kdePackages.plasma-workspace}/bin/startplasma-X11
    '';
    programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
    programs.regreet = {
      enable = true;
      settings = {
        commands = {
          reboot = ["loginctl" "reboot"];
          poweroff = ["loginctl" "poweroff"];
        };
        GTK.application_prefer_dark_theme = true;
        appearance.greeting_msg = "Welcome back to ${config.networking.hostName}!";
      };
    };
    programs.hyprland.enable = true;
  };
}
