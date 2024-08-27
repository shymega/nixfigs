{ config, ... }:
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
    upstreams."matrix-synapse".servers = { "localhost:8008" = { }; };
    virtualHosts."mtx.shymega.org.uk" = {
      forceSSL = true;
      enableACME = true;

      locations."~* ^(\/_matrix|\/_synapse)" = {
        proxyPass = "http://matrix-synapse";
      };
      locations."= /" = {
        return = "404";
      };
    };
  };
}

