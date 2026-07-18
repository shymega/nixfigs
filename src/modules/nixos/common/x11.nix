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
  enabled = checkRoles ["workstation"] config;
  sway-wrapped-hw = pkgs.writeScript "sway-wrapped-hw" ''
    #!${pkgs.runtimeShell}
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
      xserver = {
        enable = true;
        displayManager = {
          startx.enable = true;
        };
        xkb.layout = "us";
      };
      displayManager = {
        sessionPackages = let
          swayUnsupportedSession =
            (pkgs.makeDesktopItem {
              name = "sway-unsupported";
              desktopName = "Sway (Unsupported GPU)";
              comment = "Start Sway with --unsupported-gpu";
              exec = sway-wrapped-hw;
              type = "Application";
              destination = "/share/wayland-sessions";
            }).overrideAttrs (_old: {
              passthru.providedSessions = ["sway-unsupported"];
            });
        in [
          swayUnsupportedSession
        ];
      };
      desktopManager = {
        plasma6.enable = true;
      };
      libinput.enable = true;
      greetd = {
        enable = true;
        settings = {
          default_session = let
            swayConfig = pkgs.writeText "greetd-sway-config" ''
              exec "${getExe pkgs.kanshi} -c /etc/greetd/kanshi-config"
              exec "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP; ${getExe pkgs.regreet}; swaymsg exit"
              bindsym Mod4+shift+e exec swaynag \
              -t warning \
              -m 'What do you want to do?' \
              -b 'Poweroff' 'systemctl poweroff' \
              -b 'Reboot' 'systemctl reboot'
            '';
          in {
            command = "${sway-wrapped-hw} --config ${swayConfig}";
            user = "greeter";
          };
        };
      };
    };
    programs.regreet = {
      enable = true;
      settings = {
        commands = {
          reboot = ["loginctl" "reboot"];
          poweroff = ["loginctl" "poweroff"];
        };
        GTK.application_prefer_dark_theme = true;
        appearance.greeting_msg = "Welcome to ${config.networking.hostName}! Please authenticate yourself.";
      };
    };
    programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
