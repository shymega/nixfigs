{ workerName ? null
, dbGroup ? null
,
}:
{
  name = "psycopg2";
  args = {
    user = "matrix";
    password = "matrix4me";
    port = 5432;
    database = "matrix_synapse";
    sslmode = "disable";
    host = "127.0.0.1";
    application_name = "matrix-synapse (rory.gay) - ${if workerName == null then throw "synapse/db.nix: workerName unspecified" else workerName}";
    cp_min =
      if dbGroup == "solo" then
        1
      else if dbGroup == "small" then
        2
      else if dbGroup == "medium" then
        5
      else if dbGroup == "large" then
        10
      else
        throw "synapse/db.nix: Invalid dbGroup: ${if dbGroup == null then "null" else dbGroup}";
    cp_max =
      if dbGroup == "solo" then
        1
      else if dbGroup == "small" then
        2
      else if dbGroup == "medium" then
        10
      else if dbGroup == "large" then
        10
      else
        throw "synapse/db.nix: Invalid dbGroup: ${if dbGroup == null then "null" else dbGroup}";
  };
}
