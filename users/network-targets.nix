{ pkgs, ... }:

{
  systemd.user.services.network-online = {
    Unit = {
      After = [ "network.target" ];
      PartOf = [ "network-online.target" ];
      WantedBy = [ "network-online.target" ];
      Description = "Network is Online";
      RefuseManualStart = "true";
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-online-dzr.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-online-dzr.flag";
    };
  };

  systemd.user.targets.network-online = {
    Unit = {
      Requires = [ "network-online.service" ];
      Description = "Connected to a network";
    };
  };

  systemd.user.services.network-mifi = {
    Unit = {
      RefuseManualStart = "true";
      Description = "Network condition helper for MiFi connections";
      PartOf = [ "network-mifi.target" ];
      WantedBy = [ "network-mifi.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-mifi-dzr.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-mifi-dzr.flag";
    };
  };

  systemd.user.targets.network-mifi = {
    Unit = {
      Description = "Connected to MiFi";
      Requires = [ "network-mifi.service" ];
    };
  };

  systemd.user.targets.network-portal = {
    Unit = {
      Description = "Connected to captive portal";
      Requires = [ "network-portal.service" ];
    };
  };

  systemd.user.services.network-portal = {
    Unit = {
      RefuseManualStart = "true";
      Description = "Network condition helper for captive portals";
      PartOf = [ "network-portal.target" ];
      WantedBy = [ "network-portal.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-portal-dzr.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-portal-dzr.flag";
    };
  };

  systemd.user.targets.network-rnet = {
    Unit = {
      Description = "Connected to family network";
      Requires = [ "network-rnet.service" ];
    };
  };
  systemd.user.services.network-rnet = {
    Unit = {
      RefuseManualStart = "true";
      Description = "Network condition helper for family network";
      PartOf = [ "network-rnet.target" ];
      WantedBy = [ "network-rnet.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-rnet-dzr.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-rnet-dzr.flag";
    };
  };

  systemd.user.targets.network-vpn = {
    Unit = {
      Description = "Connected to a VPN";
      Requires = [ "network-vpn.service" ];
    };
  };

  systemd.user.services.network-vpn = {
    Unit = {
      RefuseManualStart = "true";
      Description = "Network condition helper for VPN connections";
      PartOf = [ "network-vpn.target" ];
      WantedBy = [ "network-vpn.target" ];

    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-vpn-dzr.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-vpn-dzr.flag";
    };
  };

  systemd.user.targets.network-wwan = {
    Unit = {
      Description = "Connected to WWAN";
      Requires = [ "network-wwan.service" ];
    };
  };

  systemd.user.services.network-wwan = {
    Unit = {
      RefuseManualStart = "true";
      Description = "Network condition helper for WWAN connections";
      PartOf = [ "network-wwan.target" ];
      WantedBy = [ "network-wwan.target" ];

    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = "true";
      ExecStart = "-${pkgs.coreutils}/bin/touch /tmp/network-wwan-dzr.flag";
      ExecStop = "-${pkgs.coreutils}/bin/rm /tmp/network-wwan-dzr.flag";
    };
  };
}
