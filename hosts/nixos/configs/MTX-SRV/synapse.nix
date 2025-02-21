{ config, ... }:
let
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
  baseUrl = "https://${fqdn}";
  adminEmail = "shymega2011@gmail.com";
in
{
  security.acme = {
    certs."${fqdn}" = {
      email = adminEmail;
      webroot = "/var/lib/acme/.challenges";
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
            "~ ^(/_matrix|/synapse|/client)".proxyPass = "http://[::1]:8008";
            "/.well-known/acme-challenge" = {
              root = "/var/lib/acme/.challenges";
            };
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
            bind_addresses = [ "::1" ];
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
      };
      extraConfigFiles = [
        config.age.secrets.synapse_secret.path
        ./extra_synapse_conf.yaml
      ];
    };

    mautrix-whatsapp = {
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
          address = "http://localhost:8008";
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
  };
}

