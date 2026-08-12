{
  config,
  lib,
  ...
}: let
  cfg = config.nixfigs.hypr.hypridle;
in {
  config = lib.mkIf cfg.enable {
    services.hypridle = {
      enable = true;
      settings = let
        mkDpms = x: "hl.dsp.dpms({ action = \"${x}\"})";
      in {
        general = {
          # Let media players (Firefox, mpv, Steam) hold off the idle timers.
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
          on_lock_cmd = "swaync-client -dn && hyprctl dispatch '${mkDpms "off"}'";
          on_unlock_cmd = "swaync-client -df && hyprctl dispatch '${mkDpms "on"}'";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch '${mkDpms "on"}'";
        };
        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 290;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 310;
            on-timeout = "hyprctl dispatch '${mkDpms "off"}'";
            on-resume = "hyprctl dispatch '${mkDpms "on"}' && brightnessctl -r";
          }
        ];
      };
    };
  };
}
