{ config, pkgs, lib, ... }:
let
  inherit (config.networking) hostName;
in
{
  systemd = {
    services = {
      chown-data = lib.mkIf (hostName == "NEO-LINUX" || hostName == "TRINITY-LINUX") {
        description = "Change permissions on /data";
        wantedBy = [ "multi-user.target" ];
        unitConfig = { RefuseManualStart = true; };
        serviceConfig.Type = "oneshot";
        script = ''
          	  chown -R 1000:100 /data/
        '';
      };
    };
  };
}