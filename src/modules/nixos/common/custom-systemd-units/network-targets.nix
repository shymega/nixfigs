# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{pkgs, ...}: let
  inherit (pkgs.lib) getExe';
in {
  systemd = {
    services = {
      network-online = {
        unitConfig = {
          PartOf = ["network-online.target"];
          Description = "Network is Online";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "true";
          ExecStart = "-${getExe' pkgs.coreutils "touch"} /tmp/network-online.flag";
          ExecStop = "-${getExe' pkgs.coreutils "rm"} /tmp/network-online.flag";
        };
        wantedBy = ["network-online.target"];
      };
      network-mifi = {
        unitConfig = {
          Description = "Network condition helper for MiFi connections";
          PartOf = ["network-mifi.target"];
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "true";
          ExecStart = "-${getExe' pkgs.coreutils "touch"} /tmp/network-mifi.flag";
          ExecStop = "-${getExe' pkgs.coreutils "rm"} /tmp/network-mifi.flag";
        };
        wantedBy = ["network-mifi.target"];
      };
      network-portal = {
        unitConfig = {
          Description = "Network condition helper for captive portals";
          PartOf = ["network-portal.target"];
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "true";
          ExecStart = "-${getExe' pkgs.coreutils "touch"} /tmp/network-portal.flag";
          ExecStop = "-${getExe' pkgs.coreutils "rm"} /tmp/network-portal.flag";
        };
        wantedBy = ["network-portal.target"];
      };
      network-rnet = {
        unitConfig = {
          Description = "Network condition helper for family network";
          PartOf = ["network-rnet.target"];
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "true";
          ExecStart = "-${getExe' pkgs.coreutils "touch"} /tmp/network-rnet.flag";
          ExecStop = "-${getExe' pkgs.coreutils "rm"} /tmp/network-rnet.flag";
        };
        wantedBy = ["network-rnet.target"];
      };
      network-vpn = {
        unitConfig = {
          Description = "Network condition helper for VPN connections";
          PartOf = ["network-vpn.target"];
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "true";
          ExecStart = "-${getExe' pkgs.coreutils "touch"} /tmp/network-vpn.flag";
          ExecStop = "-${getExe' pkgs.coreutils "rm"} /tmp/network-vpn.flag";
        };
        wantedBy = ["network-vpn.target"];
      };
    };

    targets = {
      network-mifi = {
        unitConfig = {
          Description = "Connected to MiFi";
          Requires = ["network-mifi.service"];
        };
      };

      network-portal = {
        unitConfig = {
          Description = "Connected to captive portal";
          Requires = ["network-portal.service"];
        };
      };

      network-rnet = {
        unitConfig = {
          Description = "Connected to family network";
          Requires = ["network-rnet.service"];
        };
      };
      network-vpn = {
        unitConfig = {
          Description = "Connected to a VPN";
          Requires = ["network-vpn.service"];
        };
      };
    };
  };
}
