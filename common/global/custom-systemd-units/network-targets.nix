{ pkgs, ... }:

{
  systemd.services.network-online = {
    enable = false;
    unitConfig = {
      after = [ "network.target" ];
      partOf = [ "network-online.target" ];
      wantedBy = [ "network-online.target" ];
      description = "Network is Online";
      refuseManualStart = "true";
    };
    serviceConfig = {
      type = "oneshot";
      remainAfterExit = "true";
      execStart = "-${pkgs.coreutils}/bin/touch /tmp/network-online.flag";
      execStop = "-${pkgs.coreutils}/bin/rm /tmp/network-online.flag";
    };
  };

  systemd.targets.network-online = {
    unitConfig = {
      Requires = [ "network-online.service" ];
      Description = "Connected to a network";
    };
  };

  systemd.services.network-mifi = {
    unitConfig = {
      refuseManualStart = "true";
      description = "Network condition helper for MiFi connections";
      partOf = [ "network-mifi.target" ];
      wantedBy = [ "network-mifi.target" ];
    };
    serviceConfig = {
      type = "oneshot";
      remainAfterExit = "true";
      execStart = "-${pkgs.coreutils}/bin/touch /tmp/network-mifi.flag";
      execStop = "-${pkgs.coreutils}/bin/rm /tmp/network-mifi.flag";
    };
  };

  systemd.targets.network-mifi = {
    unitConfig = {
      description = "Connected to MiFi";
      requires = [ "network-mifi.service" ];
    };
  };

  systemd.targets.network-portal = {
    unitConfig = {
      description = "Connected to captive portal";
      requires = [ "network-portal.service" ];
    };
  };

  systemd.services.network-portal = {
    unitConfig = {
      refuseManualStart = "true";
      description = "Network condition helper for captive portals";
      partOf = [ "network-portal.target" ];
      wantedBy = [ "network-portal.target" ];
    };
    serviceConfig = {
      type = "oneshot";
      remainAfterExit = "true";
      execStart = "-${pkgs.coreutils}/bin/touch /tmp/network-portal.flag";
      execStop = "-${pkgs.coreutils}/bin/rm /tmp/network-portal.flag";
    };
  };

  systemd.targets.network-rnet = {
    unitConfig = {
      description = "Connected to family network";
      requires = [ "network-rnet.service" ];
    };
  };
  systemd.services.network-rnet = {
    unitConfig = {
      refuseManualStart = "true";
      description = "Network condition helper for family network";
      partOf = [ "network-rnet.target" ];
      wantedBy = [ "network-rnet.target" ];
    };
    serviceConfig = {
      type = "oneshot";
      remainAfterExit = "true";
      execStart = "-${pkgs.coreutils}/bin/touch /tmp/network-rnet.flag";
      execStop = "-${pkgs.coreutils}/bin/rm /tmp/network-rnet.flag";
    };
  };

  systemd.targets.network-vpn = {
    unitConfig = {
      description = "Connected to a VPN";
      requires = [ "network-vpn.service" ];
    };
  };

  systemd.services.network-vpn = {
    unitConfig = {
      refuseManualStart = "true";
      description = "Network condition helper for VPN connections";
      partOf = [ "network-vpn.target" ];
      wantedBy = [ "network-vpn.target" ];

    };
    serviceConfig = {
      type = "oneshot";
      remainAfterExit = "true";
      execStart = "-${pkgs.coreutils}/bin/touch /tmp/network-vpn.flag";
      execStop = "-${pkgs.coreutils}/bin/rm /tmp/network-vpn.flag";
    };
  };

  systemd.targets.network-wwan = {
    unitConfig = {
      description = "Connected to WWAN";
      requires = [ "network-wwan.service" ];
    };
  };

  systemd.services.network-wwan = {
    unitConfig = {
      refuseManualStart = "true";
      description = "Network condition helper for WWAN connections";
      partOf = [ "network-wwan.target" ];
      wantedBy = [ "network-wwan.target" ];

    };
    serviceConfig = {
      type = "oneshot";
      remainAfterExit = "true";
      execStart = "-${pkgs.coreutils}/bin/touch /tmp/network-wwan.flag";
      execStop = "-${pkgs.coreutils}/bin/rm /tmp/network-wwan.flag";
    };
  };
}
