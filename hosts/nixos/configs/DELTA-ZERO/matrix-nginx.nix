{
  enableACME = true;
  addSSL = true;
  locations."/" = {
    proxyPass = "http://localhost:8008";
    extraConfig = ''
      if ($request_method = 'OPTIONS') {
        more_set_headers 'Access-Control-Allow-Origin: *';
        more_set_headers 'Access-Control-Allow-Methods: *';
        #
        # Custom headers and headers various browsers *should* be OK with but aren't
        #
        more_set_headers 'Access-Control-Allow-Headers: *, Authorization';
        #
        # Tell client that this pre-flight info is valid for 20 days
        #
        more_set_headers 'Access-Control-Max-Age: 1728000';
        more_set_headers 'Content-Type: text/plain; charset=utf-8';
        more_set_headers 'Content-Length: 0';
        return 204;
      }
    '';
  };

  locations."= /.well-known/matrix/server".extraConfig = ''
    more_set_headers 'Content-Type application/json';
    more_set_headers 'Access-Control-Allow-Origin *';
    return 200 '${builtins.toJSON { "m.server" = "mtx.shymega.org.uk:443"; }}';
  '';
  locations."= /.well-known/matrix/client".extraConfig = ''
    more_set_headers 'Content-Type application/json';
    more_set_headers 'Access-Control-Allow-Origin *';
    return 200 '${
      builtins.toJSON {
        "m.homeserver".base_url = "https://mtx.shymega.org.uk";
        "org.matrix.msc3575.proxy".url = "https://mtx.shymega.org.uk";
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
            matrix_id = "@shymega:mtx.shymega.org.uk";
            role = "admin";
          }
        ];
      }
    }';
  '';

  locations."~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)" = {
    proxyPass = "http://localhost:8009";
  };
}
