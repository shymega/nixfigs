# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.networking) hostName;
  inherit (lib) getExe getExe' optionalAttrs;
in {
  systemd = {
    services = {
      power-maximum-tdp = optionalAttrs (hostName == "NEO-LINUX" || hostName == "MORPHEUS-LINUX" || hostName == "DEUSEX-LINUX") {
        description = "Change TDP to maximum TDP when on AC power";
        wantedBy = [
          "multi-user.target"
          "ac.target"
        ];
        unitConfig = {
          RefuseManualStart = true;
          Requires = "ac.target";
        };
        path = with pkgs; [ryzenadj];
        serviceConfig.Type = "oneshot";
        script = ''
          ${getExe pkgs.ryzenadj} --tctl-temp=97 --stapm-limit=25000 --fast-limit=25000 --stapm-time=500 --slow-limit=25000 --slow-time=30 --vrmmax-current=70000
        '';
      };

      power-saving-tdp = optionalAttrs (hostName == "MORPHEUS-LINUX" || hostName == "DEUSEX-LINUX") {
        description = "Change TDP to power saving TDP when on battery power";
        wantedBy = ["battery.target"];
        unitConfig = {
          RefuseManualStart = true;
        };
        path = with pkgs; [ryzenadj];
        serviceConfig.Type = "oneshot";
        script = ''
          ${getExe pkgs.ryzenadj} --tctl-temp=97 --stapm-limit=7000 --fast-limit=7000 --stapm-time=500 --slow-limit=7000 --slow-time=30 --vrmmax-current=70000
        '';
      };

      powertop = optionalAttrs (hostName == "MORPHEUS-LINUX" || hostName == "TWINS-LINUX") {
        description = "Auto-tune Power Management with powertop";
        unitConfig = {
          RefuseManualStart = true;
        };
        wantedBy = [
          "multi-user.target"
          "battery.target"
        ];
        path = with pkgs; [powertop];
        serviceConfig.Type = "oneshot";
        script = ''
          ${getExe pkgs.powertop} --auto-tune
        '';
      };

      "inhibit-suspension@" = {
        description = "Inhibit suspension for one hour";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${getExe' pkgs.systemd "systemd-inhibit"} --what=sleep --why=PreventSuspension --who=system ${getExe' pkgs.toybox "sleep"} %ih";
        };
      };
    };
  };
}
