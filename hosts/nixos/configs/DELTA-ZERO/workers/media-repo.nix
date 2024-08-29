{ config, lib, ... }:

let
  cfg = config.services.matrix-synapse;
  dbGroup = "solo";
  workers = lib.range 0 (cfg.mediaRepoWorkers - 1);
  workerName = "media_repo";
  workerRoutes = {
    client = [ ];
    federation = [ ];
    media = [
      "~ ^/_matrix/client/v1/media/"
      "~ ^/_matrix/federation/v1/media/"
      "~ ^/_synapse/admin/v1/purge_media_cache$"
      "~ ^/_synapse/admin/v1/room/.*/media.*$"
      "~ ^/_synapse/admin/v1/user/.*/media.*$"
      "~ ^/_synapse/admin/v1/media/.*$"
      "~ ^/_synapse/admin/v1/quarantine_media/.*$"
      "~ ^/_matrix/media/"
    ];
  };

  enabledResources = lib.optionals (lib.length workerRoutes.client > 0) [ "client" ] ++ lib.optionals (lib.length workerRoutes.federation > 0) [ "federation" ] ++ lib.optionals (lib.length workerRoutes.media > 0) [ "media" ];
in
{
  config = lib.mkIf (cfg.mediaRepoWorkers > 0) {
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

        media_instance_running_background_jobs = "${workerName}-0";
        enable_media_repo = false;
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
              enable_media_repo = true;
              max_upload_size = "512M";
              remote_media_download_burst_count = "512G";
              remote_media_download_per_second = "512G";
              rc_federation = {
                window_size = 1;
                sleep_limit = 1000;
                sleep_delay = 1;
                reject_limit = 1000;
                concurrent = 100;
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
                    client_max_body_size 512M;
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
