{ pkgs, config, ... }:

{
  # Worker plumbing examples: https://github.com/element-hq/synapse/blob/master/docker/configure_workers_and_start.py
  # Documentation: https://github.com/element-hq/synapse/blob/develop/docs/workers.md
  imports = [ ./workers ];

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;

    nginxVirtualHostName = "mtx.shymega.org.uk";
    enableWorkers = true;

    federationSenders = 4;
    pushers = 2;
    mediaRepoWorkers = 4;
    clientReaders = 4;
    syncWorkers = 4;
    authWorkers = 1;

    federationReaders = 8;
    federationInboundWorkers = 8;

    enableAppserviceWorker = true;
    enableBackgroundWorker = true;
    enableUserDirWorker = true;

    extraConfigFiles = [
      config.age.secrets.synapse_secret.path
    ];

    eventStreamWriters = 8;

    # https://matrix-org.github.io/synapse/latest/usage/configuration/config_documentation.html
    settings = {
      server_name = "mtx.shymega.org.uk";

      enable_registration = true;
      registration_requires_token = true;

      require_membership_for_aliases = false;
      redaction_retention_period = null;
      user_ips_max_age = null;
      allow_device_name_lookup_over_federation = true;

      federation = {
        client_timeout = "60s";
        max_short_retries = 12;
        max_short_retry_delay = "5s";
        max_long_retries = 5;
        max_long_retry_delay = "30s";
      };

      listeners = [
        {
          port = 8008;
          bind_addresses = [
            "127.0.0.1"
          ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = false;
            }
          ];
        }
        {
          type = "http";
          path = "/run/matrix-synapse/main.sock";
          resources = [
            {
              names = [ "replication" ];
              compress = false;
            }
          ];
        }
      ];
      dynamic_thumbnails = true;
      presence = {
        enable = true;
        update_interval = 60;
      };
      url_preview_enabled = true;
      database = import ./db.nix {
        workerName = "main";
        dbGroup = "medium";
      };
      app_service_config_files = [
        #"/etc/matrix-synapse/appservice-registration.yaml"
        "/var/lib/matrix-synapse/modas-registration.yaml"
      ];

      max_image_pixels = "250M";

      ui_auth = {
        session_timeout = "1m";
      };

      login_via_existing_session = {
        enabled = true;
        require_ui_auth = true;
        token_timeout = "1y";
      };

      report_stats = false;

      user_directory = {
        enabled = true;
        search_all_users = true;
        prefer_local_users = true;
      };

      # https://github.com/element-hq/synapse/blob/master/synapse/config/experimental.py
      experimental_features = {
        "msc2815_enabled" = true; # Redacted event content
        "msc3026_enabled" = true; # Busy presence
        "msc3266_enabled" = true; # Room summary API
        "msc3916_authenticated_media_enabled" = true; # Authenticated media
      };

      redis = {
        enabled = true;
        path = "/run/redis-matrix-synapse/redis.sock";
      };

      instance_map = {
        main = {
          # replication listener
          path = "/run/matrix-synapse/main.sock";
        };
      };
    } // import ./ratelimits.nix // import ./caches.nix;
  };

  services.redis = {
    package = pkgs.unstable.keydb;
    servers.matrix-synapse = {
      enable = true;
      user = "matrix-synapse";
    };
  };

  systemd.tmpfiles.rules = [ "D /run/redis-matrix-synapse 0755 matrix-synapse matrix-synapse" ];
}
