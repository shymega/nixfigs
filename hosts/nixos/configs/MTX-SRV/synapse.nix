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
        homeserver = {
          software = "standard";
          domain = "${fqdn}";
          address = "https://mtx.shymega.org.uk";
        };
        appservice = {
          database = {
            type = "sqlite3-fk-wal";
            uri = "file:/var/lib/mautrix-whatsapp/data.db?_txlock=immediate";
          };

          hostname = "127.0.0.1";
          port = 29319;
          address = "http://localhost:8008";
        };

        bridge = {
          permissions = {
            "@shymega:mtx.shymega.org.uk" = "admin";
          };

          # Require encryption by default to make the bridge more secure
          encryption = {
            allow = false;
            default = false;
            require = false;

            # Recommended options from mautrix documentation
            # for optimal security.
            delete_keys = {
              dont_store_outbound = true;
              ratchet_on_decrypt = true;
              delete_fully_used_on_decrypt = true;
              delete_prev_on_new_session = true;
              delete_on_device_delete = true;
              periodically_delete_expired = true;
              delete_outdated_inbound = true;
            };


            verification_levels = {
              receive = "cross-signed-tofu";
              send = "cross-signed-tofu";
              share = "cross-signed-tofu";
            };
          };
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

        appservice = {
          hostname = "127.0.0.1";
          port = 29319;
          address = "http://localhost:8008";
        };

        # Require encryption by default to make the bridge more secure
        encryption = {
          allow = false;
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
      enable = true;
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


        appservice = {

          hostname = "127.0.0.1";
          port = 29319;
          address = "http://localhost:8008";
        };

        encryption = {
          allow = false;
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
        enable = true;
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

          appservice = {
            hostname = "127.0.0.1";
            port = 29316;
            address = "https://mtx.shymega.org.uk";
          };
          encryption = {
            allow = false;
            default = false;
            require = false;
          };
          encryption = {
            allow = false;
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
        enable = true;

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

          appservice = {
            hostname = "127.0.0.1";
            port = 29314;
            address = "https://mtx.shymega.org.uk";
          };
          encryption = {
            allow = false;
            default = false;
            require = false;
          };
          encryption = {
            allow = false;
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
        enable = true;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://mtx.shymega.org.uk";
          };
          database = {
            type = "sqlite3-fk-wal";
            uri = "file:/var/lib/mautrix-messenger/data.db?_txlock=immediate";
          };

          appservice = {
            hostname = "127.0.0.1";
            port = 29316;
          };
          # Require encryption by default to make the bridge more secure
          encryption = {
            allow = false;
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
            address = "https://mtx.shymega.org.uk";
          };
        };
      };
    };
  };
}
