{ config, lib, ... }:

let
  cfg = config.services.matrix-synapse;
  dbGroup = "medium";
  workers = lib.range 0 (cfg.federationReaders - 1);
  workerName = "federation_inbound";
  workerRoutes = {
    client = [ ];
    federation = [ "~ /_matrix/federation/(v1|v2)/send/" ];
    media = [ ];
  };

  enabledResources = lib.optionals (lib.length workerRoutes.client > 0) [ "client" ] ++ lib.optionals (lib.length workerRoutes.federation > 0) [ "federation" ] ++ lib.optionals (lib.length workerRoutes.media > 0) [ "media" ];
in
{
  config = lib.mkIf (cfg.federationInboundWorkers > 0) {
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
