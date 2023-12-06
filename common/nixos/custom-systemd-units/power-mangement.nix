# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  inherit (config.networking) hostName;
in
{
  systemd = {
    services = {
      desktop-power-maximum-tdp = lib.mkIf (hostName == "NEO-LINUX") {
        description = "Change TDP to maximum TDP when on AC power";
        wantedBy = [ "multi-user.target" ];
        unitConfig = { RefuseManualStart = true; Requires = "ac.target"; };
        path = with pkgs; [
          ryzenadj
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          ryzenadj --stapm-limit=28000 --fast-limit=28000 --slow-limit=28000 --tctl-temp=90
        '';
      };

      portable-power-saving-tdp = lib.mkIf (hostName == "UNUSED-RIGHT-NOW") {
        description = "Change TDP to power saving TDP when on battery power";
        wantedBy = [ "battery.target" ];
        unitConfig = { RefuseManualStart = true; };
        path = with pkgs; [
          ryzenadj
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          ryzenadj --stapm-limit=8000 --fast-limit=8000 --slow-limit=8000 --tctl-temp=90
        '';
      };

      powertop = lib.mkIf (hostName == "TRINITY-LINUX" || hostName == "TWINS-LINUX") {
        description = "Auto-tune Power Management with powertop";
        unitConfig = { RefuseManualStart = true; };
        path = with pkgs; [
          powertop
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          powertop --auto-tune
        '';
      };

      gpd-p3-reset-keyboard = lib.mkIf (hostName == "TRINITY-LINUX") {
        description = "Reset keyboard on the GPD Pocket 3 after Powertop runs";
        wantedBy = [
          "ac.target"
          "multi-user.target"
          "battery.target"
          "powertop.service"
        ];
        path = with pkgs; [
          coreutils
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          echo 'on' > /sys/bus/usb/devices/3-3/power/control
        '';
      };

      "inhibit-suspension@" = {
        description = "Inhibit suspension for one hour";
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            "${pkgs.systemd}/bin/systemd-inhibit --what=sleep --why=PreventSuspension --who=system /usr/bin/sleep %ih";
        };
      };
    };
  };
}
