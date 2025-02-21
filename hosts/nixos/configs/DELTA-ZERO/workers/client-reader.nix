{ config, lib, ... }:

let
  cfg = config.services.matrix-synapse;
  dbGroup = "small";
  workers = lib.range 0 (cfg.clientReaders - 1);
  workerName = "client_reader";
  workerRoutes = {
    client =
      [
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/publicRooms$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/joined_members$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/context/.*$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/members$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/state$"
        "~ ^/_matrix/client/v1/rooms/.*/hierarchy$"
        "~ ^/_matrix/client/(v1|unstable)/rooms/.*/relations/"
        "~ ^/_matrix/client/v1/rooms/.*/threads$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/messages$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/rooms/.*/event"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/joined_rooms"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable/.*)/rooms/.*/aliases"
        "~ ^/_matrix/client/v1/rooms/.*/timestamp_to_event$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/search"
        "~ ^/_matrix/client/(r0|v3|unstable)/user/.*/filter(/|$)"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/directory/room/.*$"
        "~ ^/_matrix/client/(r0|v3|unstable)/notifications$"

        # unstable
        "~ ^/_matrix/client/unstable/im.nheko.summary/rooms/.*/summary$"
      ]
      ++ lib.optionals (cfg.authWorkers == 0) [
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/login$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/account/3pid$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/account/whoami$"
        "~ ^/_matrix/client/versions$"
        "~ ^/_matrix/client/(api/v1|r0|v3|unstable)/voip/turnServer$"
        "~ ^/_matrix/client/(r0|v3|unstable)/register$"
        "~ ^/_matrix/client/(r0|v3|unstable)/register/available$"
        "~ ^/_matrix/client/(r0|v3|unstable)/auth/.*/fallback/web$"
        "~ ^/_matrix/client/(r0|v3|unstable)/password_policy$"
        "~ ^/_matrix/client/(r0|v3|unstable)/capabilities$"
      ];
    federation = [ ];
    media = [ ];
  };

  enabledResources = lib.optionals (lib.length workerRoutes.client > 0) [ "client" ] ++ lib.optionals (lib.length workerRoutes.federation > 0) [ "federation" ] ++ lib.optionals (lib.length workerRoutes.media > 0) [ "media" ];
in
{
  config = lib.mkIf (cfg.clientReaders > 0) {
    services.matrix-synapse = {
      settings = {
        instance_map = lib.listToAttrs (
          lib.map
            (index: {
              name = "${workerName}-${toString index}";
              value = {
                path = "/run/matrix-synapse/${workerName}-${toString index}.sock";
              };
            })
            workers
        );
      };

      workers = lib.listToAttrs (
        lib.map
          (index: {
            name = "${workerName}-${toString index}";
            value = {
              worker_app = "synapse.app.generic_worker";
              worker_listeners =
                [
                  {
                    type = "http";
                    path = "/run/matrix-synapse/${workerName}-${toString index}.sock";
                    resources = [
                      {
                        names = [ "replication" ];
                        compress = false;
                      }
                    ];
                  }
                ]
                ++ lib.map
                  (type: {
                    type = "http";
                    path = "/run/matrix-synapse/${workerName}-${type}-${toString index}.sock";
                    mode = "666";
                    resources = [
                      {
                        names = [ type ];
                        compress = false;
                      }
                    ];
                  })
                  enabledResources;
              database = import ../db.nix {
                inherit dbGroup;
                workerName = "${workerName}-${toString index}";
              };
            };
          })
          workers
      );
    };

    services.nginx = {
      upstreams = lib.listToAttrs (
        lib.map
          (type: {
            name = "${workerName}-${type}";
            value = {
              extraConfig = ''
                keepalive 32;
                least_conn;
              '';
              servers = lib.listToAttrs (
                lib.map
                  (index: {
                    name = "unix:/run/matrix-synapse/${workerName}-${type}-${toString index}.sock";
                    value = {
                      max_fails = 0;
                    };
                  })
                  workers
              );
            };
          })
          enabledResources
      );

      virtualHosts."${cfg.nginxVirtualHostName}".locations = lib.listToAttrs (
        lib.flatten (
          lib.forEach enabledResources (
            type:
            lib.map
              (route: {
                name = route;
                value = {
                  proxyPass = "http://${workerName}-${type}";
                  extraConfig = ''
                    proxy_http_version 1.1;
                    proxy_set_header Connection "";
                  '';
                };
              })
              workerRoutes.${type}
          )
        )
      );
    };
  };
}
