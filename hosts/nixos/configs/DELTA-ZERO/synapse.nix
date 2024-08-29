{ pkgs, ... }:
let
  fqdn = "mtx.shymega.org.uk";
in
{
  disabledModules = [
    "services/matrix/mautrix-whatsapp.nix"
  ];
  imports = [
    ../../../../modules/nixos/mautrix-slack.nix
    ../../../../modules/nixos/mautrix-whatsapp.nix
    ./postgres.nix
    ./security.nix
    ./sliding-sync.nix
    ./synapse-main.nix
  ];

  environment.systemPackages = [ pkgs.synapse ];

  services = {
    redis.servers."".enable = true;

    mautrix-whatsapp = {
      enable = false;
      registerToSynapse = false;

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
      enable = false;
      registerToSynapse = false;

      settings = {
        homeserver = {
          software = "standard";
          domain = "${fqdn}";
          address = "https://mtx.shymega.org.uk";
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
            "@shymega:mtx.shymega.org.uk" = "admin";
          };

        };
      };
    };

    mautrix-meta.instances = {
      "facebook" = {
        enable = false;
        registerToSynapse = false;

        settings = {
          homeserver = {
            software = "standard";
            domain = "${fqdn}";
            address = "https://mtx.shymega.org.uk";
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
              "@shymega:mtx.shymega.org.uk" = "admin";
            };
          };
        };
      };

      "instagram" = {
        enable = false;
        registerToSynapse = false;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://mtx.shymega.org.uk";
            domain = "${fqdn}";
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
              "@shymega:mtx.shymega.org.uk" = "admin";
            };
          };
        };
      };

      "messenger" = {
        enable = false;
        registerToSynapse = false;

        settings = {
          homeserver = {
            software = "standard";
            address = "https://mtx.shymega.org.uk";
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
