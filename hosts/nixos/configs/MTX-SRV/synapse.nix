{ config, lib, ... }:
let
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
  baseUrl = "https://${fqdn}";
  adminEmail = "shymega2011@gmail.com";
in
{
  imports = [ ./mautrix-slack.nix ];

  security.acme = {
    defaults = {
      email = adminEmail;
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_KEY_FILE" = config.age.secrets.cloudflare_dns_token.path;
      };
    };
    certs."${fqdn}" = {
      group = "nginx";
    };
    acceptTerms = true;
  };

  services = {
    postgresql.enable = true;

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
            "~ ^(/_matrix|/synapse|/client)".proxyPass = "http://127.0.0.1:8008";
          };
        };
      };
    };

    matrix-synapse = {
      enable = true;
      settings = {
        database.name = "sqlite3";
        server_name = fqdn;
        public_baseurl = baseUrl;
        listeners = [
          {
            port = 8008;
            bind_addresses = [ "::1" "127.0.0.1" "fdd0:3aca:b4a2:2c4b::1" "10.89.1.1" ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [{
              names = [ "client" "federation" ];
              compress = true;
            }];
          }
        ];
        allow_guest_access = false;
        enable_registration = false;
        app_service_config_files = lib.optionals (config.networking.hostName == "mtx") [
          /var/lib/mautrix-meta-facebook/meta-registration.yaml
          /var/lib/mautrix-meta-instagram/meta-registration.yaml
          /var/lib/mautrix-meta-messenger/meta-registration.yaml
          /var/lib/mautrix-whatsapp/whatsapp-registration.yaml
          /srv/containers/mautrix-slack/registration.yaml
        ];

      };
      extraConfigFiles = [
        config.age.secrets.synapse_secret.path
        ./extra_synapse_conf.yaml
      ];
    };

    mautrix-whatsapp = {
      enable = true;
      settings = {
        appservice = {
          as_token = "";
          bot = {
            displayname = "WhatsApp Bridge Bot";
            username = "whatsappbot";
          };
          database = {
            type = "sqlite3";
            uri = "/var/lib/mautrix-whatsapp/mautrix-whatsapp.db";
          };
          hostname = "[::]";
          hs_token = "";
          id = "whatsapp";
          port = 29318;
        };
        bridge = {
          permissions = {
            "@shymega:mtx.shymega.org.uk" = "admin";
          };

          command_prefix = "!wa";
          displayname_template = "{{if .BusinessName}}{{.BusinessName}}{{else if .PushName}}{{.PushName}}{{else}}{{.JID}}{{end}} (WA)";
          double_puppet_server_map = { };
          login_shared_secret_map = { };
          permissions = {
            "*" = "relay";
          };
          relay = {
            enabled = true;
          };
          username_template = "whatsapp_{{.}}";
        };
        homeserver = {
          address = "https://mtx.shymega.org.uk";
        };
      };
    };

    mautrix-telegram = {
      enable = false;
      settings = {
        appservice = {
          address = "http://127.0.0.1:8008";
          database = "sqlite:////var/lib//mautrix-telegram/data.db";
          database_opts = { };
          hostname = "127.0.0.1";
          port = 29324;
        };
        bridge = {
          double_puppet_server_map = { };
          login_shared_secret_map = { };
          permissions = {
            "@shymega:mtx.shymega.org.uk" = "admin";
          };
          relaybot = {
            whitelist = [ ];
          };
        };
        homeserver = {
          software = "standard";
          domain = "${fqdn}";
          address = "https://mtx.shymega.org.uk";
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
          appservice = {
            database = {
              type = "sqlite3-fk-wal";
              uri = "file:/var/lib//mautrix-fb/data.db?_txlock=immediate";
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
              allow = true;
              default = true;
              require = true;

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

      "instagram" = {
        enable = false;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://mtx.shymega.org.uk";
            domain = "${fqdn}";
          };
          appservice = {
            database = {
              type = "sqlite3-fk-wal";
              uri = "file:/var/lib//mautrix-insta/data.db?_txlock=immediate";
            };
            hostname = "127.0.0.1";
            port = 29314;
            address = "http://localhost:8008";
          };

          bridge = {
            permissions = {
              "@shymega:mtx.shymega.org.uk" = "admin";
            };

            # Require encryption by default to make the bridge more secure
            encryption = {
              allow = true;
              default = true;
              require = true;
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

      "messenger" = {
        enable = false;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://mtx.shymega.org.uk";
          };
          appservice = {
            database = {
              type = "sqlite3-fk-wal";
              uri = "file:/var/lib//mautrix-messenger/data.db?_txlock=immediate";
            };

            hostname = "127.0.0.1";
            port = 29316;
          };
          bridge = {
            permissions = {
              "@shymega:mtx.shymega.org.uk" = "admin";
            };

            # Require encryption by default to make the bridge more secure
            encryption = {
              allow = true;
              default = true;
              require = true;

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

          meta.mode = "messenger";
          homeserver.domain = "mtx.shymega.org.uk";
          appservice = {
            id = "messenger";
            bot = {
              username = "messengerbot";
              displayname = "Messenger bridge bot";
              avatar = "mxc://maunium.net/ygtkteZsXnGJLJHRchUwYWak";
            };
            address = "http://localhost:8008";
          };
        };
      };
    };
  };
}
