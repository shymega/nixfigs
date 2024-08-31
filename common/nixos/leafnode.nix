{ pkgs
, config
, ...
}:
{
  systemd = {
    services."leafnode@" = {
      requires = [ "leafnode.socket" ];
      enable = true;
      unitConfig = {
        RefuseManualStart = true;
        RefuseManualStop = true;
        Description = "Leafnode listening on %i";
      };
      serviceConfig = {
        DynamicUser = true;
        CapabilityBoundingSet = [ "" ];
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        ReadOnlyPaths = [ "/etc/leafnode/config" ];
        ReadWritePaths = [ "/var/spool/leafnode" ];
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@resources" "~@privileged" ];
        ExecStart = "${pkgs.leafnode}/bin/leafnode -d /var/spool/leafnode -F /etc/leafnode/config";
        StandardInput = "socket";
        StandardOutput = "socket";
        StandardError = "journal";
      };
    };
    sockets."leafnode" = {
      enable = true;
      wantedBy = [ "sockets.target" ];
      description = "Leafnode listener";
      listenStreams = [ "127.0.0.1:119" ];
      socketConfig.Accept = true;
    };
  };
}
