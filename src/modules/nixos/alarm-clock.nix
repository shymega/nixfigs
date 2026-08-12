# SPDX-FileCopyrightText: 2026 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.nixfigs.alarm-clock;
  user = config.users.users.${cfg.user};
in
  with lib; {
    options.nixfigs.alarm-clock = {
      enable = mkEnableOption "wake-from-suspend alarm clock";

      user = mkOption {
        type = types.str;
        default = "dzrodriguez";
        description = "User whose PipeWire session the alarm plays through.";
      };

      audioFile = mkOption {
        type = types.str;
        default = "${user.home}/.alarm.ogg";
        defaultText = literalExpression ''"''${home of nixfigs.alarm-clock.user}/.alarm.ogg"'';
        description = "Sound file to play.";
      };

      onCalendar = mkOption {
        type = types.str;
        default = "*-*-* 08:15:00";
        description = "systemd.time(7) calendar spec for when the alarm fires.";
      };

      volume = mkOption {
        type = types.ints.between 0 100;
        default = 74;
        description = ''
          Volume, as a percentage, that the default sink is forced to (and
          unmuted at) before playback, so a sink left muted or turned down
          cannot silence the alarm.
        '';
      };

      inhibitHours = mkOption {
        type = types.ints.positive;
        default = 1;
        description = ''
          Hours to inhibit suspension for once the alarm fires. Names the
          instance of nixfigs-common's inhibit-suspension@.service, whose
          ExecStart appends the "h" unit itself (sleep %ih) -- so this is a
          bare integer, not "1h".
        '';
      };

      wakeOnly = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Resume the machine at onCalendar and hold it awake, but play nothing.
          The sink is left alone. For hosts that should come back up on schedule
          without a sound going off in an empty room.
        '';
      };

      bedtime = {
        enable = mkEnableOption "scheduled nightly suspend";

        onCalendar = mkOption {
          type = types.str;
          default = "*-*-* 02:00:00";
          description = "systemd.time(7) calendar spec for when the host suspends.";
        };
      };
    };

    config = mkMerge [
      (mkIf cfg.enable {
        systemd.services.alarm-clock = {
          description =
            if cfg.wakeOnly
            then "Scheduled wake-up (silent)"
            else "Alarm clock";

          # Deliberately Wants= without a matching After=: the inhibitor is a
          # oneshot that sleeps for inhibitHours, so ordering after it would
          # hold the alarm back for that long. Unordered means concurrent.
          # It is also what stops bedtime's logind idle rules putting the
          # machine straight back to sleep on resume.
          wants = ["inhibit-suspension@${toString cfg.inhibitHours}.service"];

          serviceConfig = {
            Type = "oneshot";
            User = cfg.user;
            Group = user.group;

            # Reaches the user's PipeWire socket. Valid even with nobody logged
            # in, because the user lingers, so the user manager is always up.
            Environment = "XDG_RUNTIME_DIR=/run/user/${toString user.uid}";

            ExecStart =
              if cfg.wakeOnly
              then ["${getExe' pkgs.coreutils "true"}"]
              else [
                "${getExe' pkgs.wireplumber "wpctl"} set-volume @DEFAULT_AUDIO_SINK@ ${toString (cfg.volume / 100.0)}"
                "${getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ 0"
                "${getExe pkgs.mpv} --no-video --no-terminal --ao=pipewire ${escapeShellArg cfg.audioFile}"
              ];
          };
        };

        systemd.timers.alarm-clock = {
          description = "Alarm clock";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = cfg.onCalendar;
            WakeSystem = true;
            AccuracySec = "1s";
            Unit = "alarm-clock.service";
          };
        };
      })

      (mkIf cfg.bedtime.enable {
        systemd.services.bedtime = {
          description = "Suspend the system at bedtime";
          serviceConfig = {
            Type = "oneshot";
            # No --ignore-inhibitors: a held sleep lock (a long build, a manual
            # inhibit-suspension@N) skips bedtime for that night rather than
            # suspending out from under it.
            ExecStart = "${getExe' pkgs.systemd "systemctl"} suspend";
          };
        };

        systemd.timers.bedtime = {
          description = "Suspend the system at bedtime";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = cfg.bedtime.onCalendar;
            # Emphatically not Persistent=: a bedtime missed while powered off
            # must not fire on the next boot and suspend the machine underneath
            # whoever just turned it on.
            Unit = "bedtime.service";
          };
        };
      })
    ];
  }
