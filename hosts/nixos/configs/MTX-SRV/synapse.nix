{ config, ... }:
let
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
  baseUrl = "https://${fqdn}";
in
{
  disabledModules = [ "services/matrix/mautrix-whatsapp.nix" ];
  imports = [
    ../../../../modules/nixos/mautrix-slack.nix
    ../../../../modules/nixos/mautrix-whatsapp.nix
    ./nginx.nix
    ./security.nix
    ./postgres.nix
  ];

  users.users."matrix-synapse".extraGroups = [ "users" ];
  services = {
    matrix-synapse = {
      enable = true;
      withJemalloc = true;
      settings = {
        report_stats = false;
        enable_metrics = false;
        enable_registration = false;
        url_preview_enabled = false;
        registration_requires_token = true;
        enable_search = true;
        allow_public_rooms_over_federation = true;
        redaction_retention_period = 1;
        max_upload_size = "200M";
        experimental_features = {
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
        database.name = "psycopg2";
        allow_public_rooms_without_auth = true;
        database.args = {
          user = "matrix";
          password = "matrix4me";
          port = 5432;
          database = "matrix_synapse";
          sslmode = "disable";
          host = "localhost";
          cp_min = 5;
          cp_max = 10;
        };
        server_name = fqdn;
        dynamic_thumbnails = true;
        suppress_key_server_warning = true;
        public_baseurl = baseUrl;
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "127.0.0.1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              { compress = true; 
                names = [ "client" ]; }
              {
                compress = true;
                names = [ "federation" ]; 
              }
            ];
          }
          {
            port = 9001;
            type = "metrics";
            tls = false;
            bind_addresses = [ "127.0.0.1" ];
            resources = [ 
              {
                names = [ "metrics" ];
              }
            ];
          }
        ];
      };
      extraConfigFiles = [
        config.age.secrets.synapse_secret.path
        ./tweaks.yaml
      ];
    };

    matrix-sliding-sync.enable = true;
    matrix-sliding-sync.settings.SYNCV3_SERVER = "http://localhost:8008";
    matrix-sliding-sync.createDatabase = false;
    matrix-sliding-sync.settings.SYNCV3_DB = "host=localhost port=5432 dbname=matrix_synapse_syncv3 user=matrix password=matrix4me sslmode=disable connect_timeout=10";
    matrix-sliding-sync.settings.SYNCV3_BINDADDR = "127.0.0.1:8009";
    matrix-sliding-sync.environmentFile = config.age.secrets."matrix-sliding-sync-env".path;

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
            type = "sqlite3";
            uri = "/var/lib/mautrix-whatsapp/mautrix-whatsapp.db";
          };
          address = "http://localhost:${toString port}";
          hostname = "[::]";
          hs_token = "";
          id = "whatsapp";
          port = 29318;
        };
        bridge = {
          command_prefix = "!wa";
          displayname_template = "{{if .BusinessName}}{{.BusinessName}}{{else if .PushName}}{{.PushName}}{{else}}{{.JID}}{{end}} (WA)";
          double_puppet_server_map = { };
          login_shared_secret_map = { };
          permissions = {
            "@shymega:mtx.shymega.org.uk" = "admin";
          };
          relay = {
            enabled = true;
          };
          username_template = "whatsapp_{{.}}";
        };
        homeserver = {
          address = "https://${fqdn}";
          domain = "${fqdn}";
        };
        logging = {
          min_level = "info";
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
          domain = "${fqdn}";
          address = "https://mtx.shymega.org.uk";
        };
        database = {
          type = "sqlite3-fk-wal";
          uri = "file:/var/lib/mautrix-slack/data.db?_txlock=immediate";
        };

        appservice = rec {
          port = 29312;
          address = "http://localhost:${toString port}";
          hostname = "[::]";
        };

        # Require encryption by default to make the bridge more secure
        encryption = {
          allow = true;
          default = false;
          require = false;
        };

        bridge = {
          permissions = {
            "@shymega:mtx.shymega.org.uk" = "admin";
          };

        };
      };
    };


    mautrix-telegram = {
      enable = false;
      settings = {
        homeserver = {
          software = "standard";
          domain = "${fqdn}";
          address = "https://mtx.shymega.org.uk";
        };
        database = {
          type = "sqlite3-fk-wal";
          uri = "file:/var/lib/mautrix-telegram/data.db?_txlock=immediate";
        };


        appservice = rec {
          port = 29313;
          address = "http://localhost:${toString port}";
          hostname = "[::]";
        };

        encryption = {
          allow = true;
          default = false;
          require = false;

        };

        bridge = {
          permissions = {
            "@shymega:mtx.shymega.org.uk" = "admin";
          };

        };
      };
    };

    mautrix-meta.instances = {
      "facebook" = {
        enable = false;
        settings = {
          homeserver = {
            software = "standard";
            domain = "${fqdn}";
            address = "https://mtx.shymega.org.uk";
          };
          database = {
            type = "sqlite3-fk-wal";
            uri = "file:/var/lib/mautrix-facebook/data.db?_txlock=immediate";
          };

          appservice = rec {
            port = 29314;
            address = "http://localhost:${toString port}";
            hostname = "[::]";

          };
          encryption = {
            allow = true;
            default = false;
            require = false;
          };

          bridge = {
            permissions = {
              "@shymega:mtx.shymega.org.uk" = "admin";
            };
          };
        };
      };

      "instagram" = {
        enable = false;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://mtx.shymega.org.uk";
            domain = "${fqdn}";
          };
          database = {
            type = "sqlite3-fk-wal";
            uri = "file:/var/lib/mautrix-instagram/data.db?_txlock=immediate";
          };

          appservice = rec {
            port = 29314;
            address = "http://localhost:${toString port}";
            hostname = "[::]";
          };
          encryption = {
            allow = true;
            default = false;
            require = false;
          };

          bridge = {
            permissions = {
              "@shymega:mtx.shymega.org.uk" = "admin";
            };
          };
        };
      };

      "messenger" = {
        enable = false;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://mtx.shymega.org.uk";
          };
          database = {
            type = "sqlite3-fk-wal";
            uri = "file:/var/lib/mautrix-messenger/data.db?_txlock=immediate";
          };

          appservice = rec {
            port = 29316;
            address = "http://localhost:${toString port}";
            hostname = "[::]";

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
            default = false;
            require = false;
          };

          bridge = {
            permissions = {
              "@shymega:mtx.shymega.org.uk" = "admin";
            };

          };

          meta.mode = "messenger";
          homeserver.domain = "mtx.shymega.org.uk";
        };
      };
    };
  };
}
