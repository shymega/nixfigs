{ pkgs, ... }:

{
  systemd.services.network-mifi = {
    description = "Network condition helper for MiFi connections";
    partOf = [ "network-mifi.target" ];
    wantedBy = [ "network-mifi.target" ];
    environment = { };
    unitConfig = { RefuseManualStart = "true"; };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-mifi.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-mifi.flag";
    };
  };

  systemd.targets.network-mifi = {
    description = "Connected to MiFi";
    requires = [ "network-mifi.service" ];
  };

  systemd.services.network-online = {
    after = [ "network.target" ];
    description = "Network is Online";
    documentation = [
      "man:systemd.special(7)"
      "https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget"
    ];
    partOf = [ "network-online.target" ];
    wantedBy = [ "network-online.target" ];
    environment = { };
    unitConfig = { RefuseManualStart = "true"; };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-online.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-online.flag";
    };
  };
}
