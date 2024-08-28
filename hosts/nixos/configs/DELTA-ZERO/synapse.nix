{ pkgs, ... }:
let
  fqdn = "mtx.shymega.org.uk";
in
{
  disabledModules = [ "services/matrix/mautrix-whatsapp.nix" ];
  imports = [
    ../../../../modules/nixos/mautrix-slack.nix
    ../../../../modules/nixos/mautrix-whatsapp.nix
    ../../../../modules/nixos/nixos-matrix/synapse-module
    ../../../../modules/nixos/nixos-matrix/sliding-sync
    ./security.nix
    ./postgres.nix
  ];
  nixpkgs.overlays = [
    (_final: _prev: {
      inherit (inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}) matrix-synapse-unwrapped;
    })
  ];

  environment.systemPackages = [ pkgs.synapse ];

  services = {
    matrix-synapse-next = {
      enable = true;

      workers.federationSenders = 1;
      workers.federationReceivers = 1;
      workers.initialSyncers = 1;
      workers.normalSyncers = 1;
      workers.eventPersisters = 2;
      workers.useUserDirectoryWorker = true;

      enableNginx = true;

      settings = {
        extraConfigFiles = [
          config.age.secrets.synapse_secret.path
          ./synapse/tweaks.yaml
          ./synapse/logging.yaml
        ];

        public_baseurl = "https://mtx.shymega.org.uk";
        server_name = "mtx.shymega.org.uk";
        database = {
          name = "psycopg2";
          args = {
            user = "matrix";
            password = "matrix4me";
            port = 5432;
            database = "matrix_synapse";
            sslmode = "disable";
            host = "127.0.0.1";
            cp_min = 5;
            cp_max = 10;
          };
        };
        report_stats = true;
        enable_metrics = true;
        enable_registration = true;
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
        enableSlidingSync = true;
      };
      sliding-sync = {
        enable = true;
        environmentFile = config.age.secrets.matrix-sliding-sync-env.path;
        publicBaseUrl = "https://mtx.shymega.org.uk";
        settings = {
          SYNCV3_SERVER = "http://localhost:8008";
          SYNCV3_DB = "host=localhost port=5432 dbname=matrix_syncv3 user=matrix password=matrix4me sslmode=disable connect_timeout=10";
          SYNCV3_LOG_LEVEL = "trace";
          SYNCV3_BINDADDR = "127.0.0.1:8009";
        };
      };
    };

    redis.servers."".enable = true;
    #        app_service_config_files = [
    #          /var/lib/mautrix-meta-facebook/meta-registration.yaml
    #          /var/lib/mautrix-meta-instagram/meta-registration.yaml
    #          /var/lib/mautrix-meta-messenger/meta-registration.yaml
    #          /var/lib/mautrix-slack/slack-registration.yaml
    #          /var/lib/mautrix-whatsapp/whatsapp-registration.yaml
    #        ];

    mautrix-whatsapp = {
      enable = true;
      registerToSynapse = true;

      settings = {
        appservice = rec  {
          as_token = "";
          bot = {
            displayname = "WhatsApp Bridge Bot";
            username = "whatsappbot";
          };
          database = {
            type = "postgres";
            uri = "postgres://matrix:matrix4me@127.0.0.1/mautrix_whatsapp?sslmode=disable";
          };
          address = "http://127.0.0.1:${toString port}";
          hostname = "127.0.0.1";
          id = "whatsapp";
          port = 29318;
        };
        bridge = {
          command_prefix = "!wa";
          displayname_template = "{{if .BusinessName}}{{.BusinessName}}{{else if .PushName}}{{.PushName}}{{else}}{{.JID}}{{end}} (WA)";
          double_puppet_server_map = { };
          login_shared_secret_map = { };
          permissions = {
            "@shymega:rodriguez.org.uk" = "admin";
          };
          relay = {
            enabled = true;
          };
          username_template = "whatsapp_{{.}}";
        };
        homeserver = {
          address = "https://${fqdn}";
          domain = "rodriguez.org.uk";
        };
        logging = {
          min_level = "debug";
          writers = [
            {
              format = "pretty-colored";
              time_format = " ";
              type = "stdout";
            }
          ];
        };
      };
    };

    mautrix-slack = {
      enable = true;
      registerToSynapse = true;

      settings = {
        homeserver = {
          software = "standard";
          domain = "rodriguez.org.uk";
          address = "https://matrix.rodriguez.org.uk";
        };
        database = {
          type = "postgres";
          uri = "postgres://matrix:matrix4me@127.0.0.1/mautrix_slack?sslmode=disable";
        };

        appservice = rec {
          port = 29312;
          address = "http://127.0.0.1:${toString port}";
          hostname = "127.0.0.1";
        };

        # Require encryption by default to make the bridge more secure
        encryption = {
          allow = true;
          default = true;
          require = true;
        };

        bridge = {
          permissions = {
            "@shymega:rodriguez.org.uk" = "admin";
          };

        };
      };
    };


    mautrix-telegram = {
      enable = false;

      settings = {
        homeserver = {
          software = "standard";
          domain = "rodriguez.org.uk";
          address = "https://matrix.rodriguez.org.uk";
        };
        database = {
          type = "postgres";
          uri = "postgres://matrix:matrix4me@127.0.0.1/mautrix_telegram?sslmode=disable";

        };


        appservice = rec {
          port = 29313;
          address = "http://127.0.0.1:${toString port}";
          hostname = "127.0.0.1";
        };

        encryption = {
          allow = true;
          default = true;
          require = true;

        };

        bridge = {
          permissions = {
            "@shymega:rodriguez.org.uk" = "admin";
          };

        };
      };
    };

    mautrix-meta.instances = {
      "facebook" = {
        enable = true;
        registerToSynapse = true;

        settings = {
          homeserver = {
            software = "standard";
            domain = "rodriguez.org.uk";
            address = "https://matrix.rodriguez.org.uk";
          };
          database = {
            type = "postgres";
            uri = "postgres://matrix:matrix4me@127.0.0.1/mautrix_meta_facebook?sslmode=disable";
          };

          appservice = rec {
            port = 29314;
            address = "http://127.0.0.1:${toString port}";
            hostname = "127.0.0.1";

          };
          encryption = {
            allow = true;
            default = true;
            require = true;
          };

          bridge = {
            permissions = {
              "@shymega:rodriguez.org.uk" = "admin";
            };
          };
        };
      };

      "instagram" = {
        enable = true;
        registerToSynapse = true;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://matrix.rodriguez.org.uk";
            domain = "rodriguez.org.uk";
          };
          database = {
            type = "postgres";
            uri = "postgres://matrix:matrix4me@127.0.0.1/mautrix_meta_instagram?sslmode=disable";

          };

          appservice = rec {
            port = 29314;
            address = "http://127.0.0.1:${toString port}";
            hostname = "127.0.0.1";
          };
          encryption = {
            allow = true;
            default = true;
            require = true;
          };

          bridge = {
            permissions = {
              "@shymega:rodriguez.org.uk" = "admin";
            };
          };
        };
      };

      "messenger" = {
        enable = true;
        registerToSynapse = true;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://matrix.rodriguez.org.uk";
          };
          database = {
            type = "postgres";
            uri = "postgres://matrix:matrix4me@127.0.0.1/mautrix_meta_messenger?sslmode=disable";
          };

          appservice = rec {
            port = 29316;
            address = "http://127.0.0.1:${toString port}";
            hostname = "127.0.0.1";

            id = "messenger";
            bot = {
              username = "messengerbot";
              displayname = "Messenger bridge bot";
              avatar = "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
            };
          };

          # Require encryption by default to make the bridge more secure
          encryption = {
            allow = true;
            default = true;
            require = true;
          };

          bridge = {
            permissions = {
              "@shymega:rodriguez.org.uk" = "admin";
            };

          };

          meta.mode = "messenger";
          homeserver.domain = "matrix.rodriguez.org.uk";
        };
      };
    };
  };
}
