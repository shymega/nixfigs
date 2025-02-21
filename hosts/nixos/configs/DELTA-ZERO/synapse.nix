{ inputs, pkgs, ... }:
let
  fqdn = "matrix.rodriguez.org.uk";
in
{
  disabledModules = [ "services/matrix/mautrix-whatsapp.nix" ];
  imports = [
    ../../../../modules/nixos/mautrix-slack.nix
    ../../../../modules/nixos/mautrix-whatsapp.nix
    ./security.nix
    ./postgres.nix
    ./nginx.nix
    ./synapse-main.nix
  ];
  nixpkgs.overlays = [
    (_final: _prev: {
      inherit (inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}) matrix-synapse-unwrapped;
    })
  ];

  system.activationScripts."mautrix-perms".text = ''
    ${pkgs.coreutils}/bin/chgrp -Rv matrix-synapse /var/lib/mautrix-meta-facebook /var/lib/mautrix-meta-instagram /var/lib/mautrix-meta-messenger /var/lib/mautrix-slack /var/lib/mautrix-telegram /var/lib/mautrix-whatsapp
  '';

  environment.systemPackages = [ pkgs.synapse ];

  services = {
    redis.servers."".enable = true;

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
            "@dom:rodriguez.org.uk" = "admin";
          };
          relay = {
            enabled = true;
          };
          username_template = "whatsapp_{{.}}";
        };
        homeserver = {
          software = "standard";

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
          address = "https://${fqdn}";
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
            "@dom:rodriguez.org.uk" = "admin";
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
          address = "https://${fqdn}";
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
            "@dom:rodriguez.org.uk" = "admin";
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
            address = "https://${fqdn}";
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
              "@dom:rodriguez.org.uk" = "admin";
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
            address = "https://${fqdn}";
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
              "@dom:rodriguez.org.uk" = "admin";
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
            domain = "rodriguez.org.uk";
            address = "https://${fqdn}";
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
              "@dom:rodriguez.org.uk" = "admin";
            };

          };

          meta.mode = "messenger";
        };
      };
    };
  };
}
