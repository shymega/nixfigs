{ pkgs, ... }:
{
  services = {
    postgresql = {
      enable = true;
      ensureDatabases = [ "mautrix_slack" "mautrix_whatsapp" "mautrix_meta_facebook" "mautrix_meta_instagram" "mautrix_meta_messenger" "mautrix_telegram" "matrix_synapse_syncv3" ];
      enableTCPIP = true;
      settings.port = 5432;
      authentication = pkgs.lib.mkOverride 10 ''
        #...
        #type database DBuser origin-address auth-method
        # ipv4
        host  all      all     127.0.0.1/32   trust
        # ipv6
        host all       all     ::1/128        trust
        #type database  DBuser  auth-method
        local all       all     trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE matrix WITH LOGIN PASSWORD 'matrix4me' CREATEDB;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public to matrix;
      '';
    };
  };
}
