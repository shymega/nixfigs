{ pkgs, ... }:

{
  systemd.services.network-online = {
    enable = false;
    unitConfig = {
      After = [ "network.target" ];
      PartOf = [ "network-online.target" ];
      WantedBy = [ "network-online.target" ];
      Description = "Network is Online";
      RefuseManualStart = "true";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-online.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-online.flag";
    };
  };

  systemd.services.network-mifi = {
    unitConfig = {
      RefuseManualStart = "true";
      Description = "Network condition helper for MiFi connections";
      PartOf = [ "network-mifi.target" ];
      WantedBy = [ "network-mifi.target" ];
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-mifi.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-mifi.flag";
    };
  };

  systemd.targets.network-mifi = {
    unitConfig = {
      Description = "Connected to MiFi";
      Requires = [ "network-mifi.service" ];
    };
  };

  systemd.targets.network-portal = {
    unitConfig = {
      Description = "Connected to captive portal";
      Requires = [ "network-portal.service" ];
    };
  };

  systemd.services.network-portal = {
    unitConfig = {
      RefuseManualStart = "true";
      Description = "Network condition helper for captive portals";
      PartOf = [ "network-portal.target" ];
      WantedBy = [ "network-portal.target" ];
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-portal.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-portal.flag";
    };
  };

  systemd.targets.network-rnet = {
    unitConfig = {
      Description = "Connected to family network";
      Requires = [ "network-rnet.service" ];
    };
  };
  systemd.services.network-rnet = {
    unitConfig = {
      RefuseManualStart = "true";
      Description = "Network condition helper for family network";
      PartOf = [ "network-rnet.target" ];
      WantedBy = [ "network-rnet.target" ];
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-rnet.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-rnet.flag";
    };
  };

  systemd.targets.network-vpn = {
    unitConfig = {
      Description = "Connected to a VPN";
      Requires = [ "network-vpn.service" ];
    };
  };

  systemd.services.network-vpn = {
    unitConfig = {
      RefuseManualStart = "true";
      Description = "Network condition helper for VPN connections";
      PartOf = [ "network-vpn.target" ];
      WantedBy = [ "network-vpn.target" ];

    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-vpn.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-vpn.flag";
    };
  };

  systemd.targets.network-wwan = {
    unitConfig = {
      Description = "Connected to WWAN";
      Requires = [ "network-wwan.service" ];
    };
  };

  systemd.services.network-wwan = {
    unitConfig = {
      RefuseManualStart = "true";
      Description = "Network condition helper for WWAN connections";
      PartOf = [ "network-wwan.target" ];
      WantedBy = [ "network-wwan.target" ];

    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-wwan.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-wwan.flag";
    };
  };
}
