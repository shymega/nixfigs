# SPDX-FileCopyrightText: 2024 Various Authors <generic@example.com>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, config, ... }:

{
  # Worker plumbing examples: https://github.com/element-hq/synapse/blob/master/docker/configure_workers_and_start.py
  # Documentation: https://github.com/element-hq/synapse/blob/develop/docs/workers.md
  #  imports = [ ./workers ];

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;

    extraConfigFiles = [
      config.age.secrets.synapse_secret.path
      ./synapse/tweaks.yaml
      ./synapse/logging.yaml
    ];

    # https://matrix-org.github.io/synapse/latest/usage/configuration/config_documentation.html
    settings = {
      server_name = "rodriguez.org.uk";
      report_stats = true;
      enable_metrics = true;
      enable_registration = true;
      url_preview_enabled = true;
      registration_requires_token = true;
      enable_search = true;
      allow_public_rooms_over_federation = true;
      max_upload_size = "20M";
      allow_public_rooms_without_auth = true;
      federation = {
        client_timeout = "60s";
        max_short_retries = 12;
        max_short_retry_delay = "5s";
        max_long_retries = 5;
        max_long_retry_delay = "30s";
      };
      presence = {
        enable = true;
        update_interval = 60;
      };
      require_membership_for_aliases = false;
      redaction_retention_period = null;
      user_ips_max_age = null;
      allow_device_name_lookup_over_federation = true;

      experimental_features = {
        msc2815_enabled = true; # Redacted event content
        msc3026_enabled = true; # Busy presence
        msc3916_authenticated_media_enabled = true; # Authenticated media
        # Room summary api
        msc3266_enabled = true;
        # Removing account data
        msc3391_enabled = true;
        # Thread notifications
        msc3773_enabled = true;
        # Remotely toggle push notifications for another client
        msc3881_enabled = true;
        # Remotely silence local notifications
        msc3890_enabled = true;
      };
      suppress_key_server_warning = true;

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
      ];
      dynamic_thumbnails = true;
      database = import ./db.nix {
        workerName = "main";
        dbGroup = "medium";
      };
      max_image_pixels = "250M";

      ui_auth = {
        session_timeout = "1m";
      };

      login_via_existing_session = {
        enabled = true;
        require_ui_auth = true;
        token_timeout = "1y";
      };

      user_directory = {
        enabled = true;
        search_all_users = true;
        prefer_local_users = true;
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
    } // import ./caches.nix;
  };

  services.redis = {
    package = pkgs.unstable.redis;
    servers.matrix-synapse = {
      enable = true;
      user = "matrix-synapse";
    };
    servers."".enable = true;
  };

  systemd.tmpfiles.rules = [ "D /run/redis-matrix-synapse 0755 matrix-synapse matrix-synapse" ];
}
