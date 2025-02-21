{ config, ... }:
{
  # configure restic backup services
  services.restic.backups = {
    shynet-machines = {
      initialize = true;

      environmentFile = config.age.secrets."restic_env".path;
      repositoryFile = config.age.secrets."restic_repo".path;
      passwordFile = config.age.secrets."restic_pw".path;

      paths = [
        "${config.users.users.dzrodriguez.home}"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };

  systemd.services.restic-backups-shynet-machines = {
    unitConfig.OnFailure = "unit-failure@%n.service";
    serviceConfig.TimeoutSec = "25200s";
  };
}
