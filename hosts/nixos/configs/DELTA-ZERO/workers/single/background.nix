{ config, lib, ... }:

let
  cfg = config.services.matrix-synapse;
  dbGroup = "small";
  workerName = "background";
  workerRoutes = {
    client = [ ];
    federation = [ ];
    media = [ ];
  };

  enabledResources = lib.optionals (lib.length workerRoutes.client > 0) [ "client" ] ++ lib.optionals (lib.length workerRoutes.federation > 0) [ "federation" ] ++ lib.optionals (lib.length workerRoutes.media > 0) [ "media" ];
in
{
  config = lib.mkIf cfg.enableBackgroundWorker {
    services.matrix-synapse = {
      settings = {
        instance_map = {
          ${workerName} = {
            path = "/run/matrix-synapse/${workerName}.sock";
          };
        };

        run_background_tasks_on = workerName;
      };

      workers = {
        ${workerName} = {
          worker_app = "synapse.app.generic_worker";
          worker_listeners =
            [
              {
                type = "http";
                path = "/run/matrix-synapse/${workerName}.sock";
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
                path = "/run/matrix-synapse/${workerName}-${type}.sock";
                mode = "666";
                resources = [
                  {
                    names = [ type ];
                    compress = false;
                  }
                ];
              })
              enabledResources;

          database = import ../../db.nix { inherit workerName dbGroup; };
        };
      };
    };

    services.nginx = {
      virtualHosts."${cfg.nginxVirtualHostName}".locations = lib.listToAttrs (
        lib.flatten (
          lib.forEach enabledResources (
            type:
            lib.map
              (route: {
                name = route;
                value = {
                  proxyPass = "http://unix:/run/matrix-synapse/${workerName}-${type}.sock";
                };
              })
              workerRoutes.${type}
          )
        )
      );
    };
  };
}
