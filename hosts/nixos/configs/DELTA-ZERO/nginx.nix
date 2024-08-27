{ config, ... }:
let
  clientConfig = {
    "m.homeserver" = {
      "base_url" = "https://mtx.shymega.org.uk";
    };
    "m.identity_server" = {
      "base_url" = "https://vector.im";
    };
    "org.matrix.msc3575.proxy" = {
      "url" = "https://mtx.shymega.org.uk";
    };
  };
  serverConfig."m.server" = "mtx.shymega.org.uk:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
  };

  # Grant nginx access to certificates
  systemd.services.nginx.serviceConfig.SupplementaryGroup = [ "acme" ];

  # Reload nginx after certificate renewal
  security.acme.defaults.reloadServices = [ "nginx.service" ];

  services.nginx = {
    enable = true;
    enableReload = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedZstdSettings = true;
    clientMaxBodySize = config.services.matrix-synapse.settings.max_upload_size;
    virtualHosts."mtx.shymega.org.uk" = {
      forceSSL = true;
      enableACME = true;
      # forward all Matrix API calls to synapse
      locations."~ ^(/_matrix|/_synapse/_client)" = {
        proxyPass = "http://127.0.0.1:8008";
        extraConfig = ''
          proxy_connect_timeout       300;
          proxy_send_timeout          300;
          proxy_read_timeout          300;
          send_timeout                300;
        '';
      };
      locations."~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
        proxyPass = "http://127.0.0.1:8009";
        extraConfig = ''
          proxy_connect_timeout       300;
          proxy_send_timeout          300;
          proxy_read_timeout          300;
          send_timeout                300;
        '';
      };
      locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
      locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
      locations."= /".return = "404";
    };
  };
}

