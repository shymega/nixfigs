{ config, ... }:
{
  services.matrix-sliding-sync = {
    enable = true;
    createDatabase = true;
    settings = {
      "SYNCV3_SERVER" = "http://matrix.rodriguez.org.uk";
      "SYNCV3_BINDADDR" = "0.0.0.0:8009";
    };
    environmentFile = config.age.secrets.matrix-sliding-sync-env.path;
  };
}
