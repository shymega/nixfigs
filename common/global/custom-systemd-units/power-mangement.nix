{ config, pkgs, lib, ...}:

{
  systemd.services.power-maximum-tdp = lib.mkIf (config.networking.hostName == "NEO-LINUX") {
    description = "Change TDP to maximum TDP when on AC power";
    wantedBy = [ "ac.target" ];
    unitConfig = { RefuseManualStart = true; };
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=28000 --fast-limit=28000 --slow-limit=28000 --tctl-temp=90";
    };
  };

  systemd.services.power-saving-tdp = lib.mkIf (config.networking.hostName == "NEO-LINUX") {
    description = "Change TDP to power saving TDP when on battery power";
    wantedBy = [ "battery.target" ];
    unitConfig = { RefuseManualStart = true; };
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=8000 --fast-limit=8000 --slow-limit=8000 --tctl-temp=90";
    };
  };

  systemd.services.powertop = {
    description = "Auto-tune Power Management with powertop";
    unitConfig = { RefuseManualStart = true; };
    wantedBy = [ "battery.target" "ac.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
    };
  };

  systemd.services."inhibit-suspension@" = {
    description = "Inhibit suspension for one hour";
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        "${pkgs.systemd}/bin/systemd-inhibit --what=sleep --why=PreventSuspension --who=system /usr/bin/sleep %ih";
    };
  };
}
