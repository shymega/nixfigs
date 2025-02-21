# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{ config
, pkgs
, lib
, ...
}:
let
  inherit (config.networking) hostName;
in
{
  systemd = {
    services = {
      desktop-power-maximum-tdp = lib.mkIf (hostName == "NEO-LINUX" || hostName == "MORPHEUS-LINUX") {
        description = "Change TDP to maximum TDP when on AC power";
        wantedBy = [
          "multi-user.target"
          "ac.target"
        ];
        unitConfig = {
          RefuseManualStart = true;
          Requires = "ac.target";
        };
        path = with pkgs.unstable; [ ryzenadj ];
        serviceConfig.Type = "oneshot";
        script = ''
          ryzenadj --tctl-temp=97 --stapm-limit=25000 --fast-limit=25000 --stapm-time=500 --slow-limit=25000 --slow-time=30 --vrmmax-current=70000
        '';
      };

      portable-power-saving-tdp = lib.mkIf (hostName == "MORPHEUS-LINUX") {
        description = "Change TDP to power saving TDP when on battery power";
        wantedBy = [ "battery.target" ];
        unitConfig = {
          RefuseManualStart = true;
        };
        path = with pkgs.unstable; [ ryzenadj ];
        serviceConfig.Type = "oneshot";
        script = ''
          ryzenadj --tctl-temp=97 --stapm-limit=7000 --fast-limit=7000 --stapm-time=500 --slow-limit=7000 --slow-time=30 --vrmmax-current=70000
        '';
      };

      powertop = lib.mkIf (hostName == "MORPHEUS-LINUX" || hostName == "TWINS-LINUX") {
        description = "Auto-tune Power Management with powertop";
        unitConfig = {
          RefuseManualStart = true;
        };
        wantedBy = [
          "ac.target"
          "multi-user.target"
          "battery.target"
        ];
        path = with pkgs.unstable; [ powertop ];
        serviceConfig.Type = "oneshot";
        script = ''
          powertop --auto-tune
        '';
      };

      "inhibit-suspension@" = {
        description = "Inhibit suspension for one hour";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep --why=PreventSuspension --who=system ${pkgs.toybox}/bin/sleep %ih";
        };
      };
    };
  };
}
