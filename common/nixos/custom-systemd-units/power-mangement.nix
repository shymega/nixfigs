# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  inherit (config.networking) hostName;
in
{
  systemd = {
    services = {
      desktop-power-maximum-tdp = lib.mkIf (hostName == "NEO-LINUX" || hostName == "MORPHEUS-LINUX") {
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

      portable-power-saving-tdp = lib.mkIf (hostName == "MORPHEUS-LINUX") {
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

      powertop = lib.mkIf
        (hostName == "MORPHEUS-LINUX" || hostName == "TWINS-LINUX")
        {
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

      gpd-wm2-2024-fixes = lib.mkIf (hostName == "MORPHEUS-LINUX") {
        description = "Fix hw on GPD WM2 2024";
        wantedBy = [
          "ac.target"
          "multi-user.target"
          "battery.target"
        ];
        path = with pkgs; [
          coreutils
          awk
          bash
        ];
        serviceConfig.Type = "oneshot";
        script = ''
          	  echo 0 > /sys/bus/usb/devices/usb1/1-4/authorized
          	  echo disabled > /sys/bus/i2c/devices/i2c-GXTP7385:00/power/wakeup
          	  echo disabled > /sys/bus/i2c/devices/i2c-PNP0C50:00/power/wakeup
          	  for i in $(cat /proc/acpi/wakeup|grep enabled|awk '{print $1}'|xargs); do 
          	  	case $i in
          		 SLPB|XHCI)
          		   ;;
          		 *) 
          		   echo $i | tee /proc/acpi/wakeup;
          		 esac; 
          	  done
        '';
      };

      "inhibit-suspension@" = {
        description = "Inhibit suspension for one hour";
        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            "${pkgs.systemd}/bin/systemd-inhibit --what=sleep --why=PreventSuspension --who=system ${pkgs.toybox}/bin/sleep %ih";
        };
      };
    };
  };
}
