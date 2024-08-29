_:
{
  services.matrix-sliding-sync = {
    enable = true;
    settings = {
      "SYNCV3_SERVER" = "http://matrix.rory.gay";
      "SYNCV3_DB" = "postgresql://%2Frun%2Fpostgresql/syncv3";
      "SYNCV3_BINDADDR" = "0.0.0.0:8100";
    };
    environmentFile = "/etc/sliding-sync.env";
  };
}
