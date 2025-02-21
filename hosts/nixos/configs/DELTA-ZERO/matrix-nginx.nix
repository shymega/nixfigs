{
  enableACME = true;
  forceSSL = true;
  sslCertificate = "/etc/origin.crt";
  sslCertificateKey = "/etc/origin.key";
  locations."~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
    proxyPass = "http://localhost:8009";
    extraConfig = ''
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $host;
      proxy_http_version 1.1;
      proxy_set_header Access-Control-Allow-Origin *;
    '';
  };
  locations."~ ^/(_matrix|_synapse|_client)" = {
    proxyPass = "http://localhost:8008";
    extraConfig = ''
      proxy_set_header X-Forwarded-For $remote_addr;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $host;
      proxy_http_version 1.1;
      proxy_set_header Access-Control-Allow-Origin *;
    '';
  };
  locations."= /.well-known/matrix/server".extraConfig = ''
    more_set_headers 'Content-Type application/json';
    more_set_headers 'Access-Control-Allow-Origin *';
    return 200 '${builtins.toJSON { "m.server" = "matrix.rodriguez.org.uk:443"; }}';
  '';
  locations."= /.well-known/matrix/client".extraConfig = ''
    more_set_headers 'Content-Type application/json';
    more_set_headers 'Access-Control-Allow-Origin *';
    return 200 '${
      builtins.toJSON {
        "m.homeserver".base_url = "https://matrix.rodriguez.org.uk";
        "org.matrix.msc3575.more".url = "https://matrix.rodriguez.org.uk";
      }
    }';
  '';
  locations."= /.well-known/matrix/support".extraConfig = ''
    more_set_headers 'Content-Type application/json';
    more_set_headers 'Access-Control-Allow-Origin *';
    return 200 '${
      builtins.toJSON {
        admins = [
          {
            matrix_id = "@shymega:rodriguez.org.uk";
            role = "admin";
          }
        ];
      }
    }';
  '';
}
