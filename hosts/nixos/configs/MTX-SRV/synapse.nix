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
    ./security.nix
    ./postgres.nix
  ];

  users.users."matrix-synapse".extraGroups = [ "users" ];

  services = {
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "${fqdn}" = {
          listen = [
            { addr = "[::]"; port = 443; ssl = true; }
            { addr = "0.0.0.0"; port = 443; ssl = true; }
          ];
          enableACME = true;
          forceSSL = true;
          locations = {
            "/".extraConfig = ''
              return 404;
            '';
            "/_matrix".proxyPass = "http://127.0.0.1:8008";
            "/_synapse".proxyPass = "http://127.0.0.1:8008";
          };
        };
      };
    };

    matrix-synapse = {
      enable = true;
      settings = {
        database.name = "sqlite3";
        presence.enabled = false;
        server_name = fqdn;
        enable_metrics = true;
        report_stats = true;
        dynamic_thumbnails = true;
        suppress_key_server_warning = true;
        public_baseurl = baseUrl;
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "::1" "127.0.0.1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [{
              names = [ "client" "federation" ];
              compress = true;
            }];
          }
        ];
        allow_guest_access = true;
        enable_registration = false;
      };
      extraConfigFiles = [
        config.age.secrets.synapse_secret.path
        ./tweaks.yaml
      ];
    };

    mautrix-whatsapp = {
      enable = true;
      registerToSynapse = true;
      settings = {
        appservice = rec {
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
          appservice = {
            id = "messenger";
            bot = {
              username = "messengerbot";
              displayname = "Messenger bridge bot";
              avatar = "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
            };
          };
        };
      };
    };
  };
}
