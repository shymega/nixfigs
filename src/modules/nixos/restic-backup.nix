# SPDX-FileCopyrightText: 2026 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixfigs.resticBackup;
in {
  options.nixfigs.resticBackup = {
    enable = mkEnableOption "scheduled restic backups to Backblaze B2";

    bucket = mkOption {
      type = types.str;
      description = "Backblaze B2 bucket name.";
    };

    repositoryPath = mkOption {
      type = types.str;
      default = config.networking.hostName;
      defaultText = literalExpression "config.networking.hostName";
      description = ''
        Path within the B2 bucket used as this host's restic repository.
        Kept per-host (rather than one shared repository) to avoid restic
        lock contention between MJOLNIR, DEUSEX and MORPHEUS backing up
        concurrently.
      '';
    };

    paths = mkOption {
      type = types.listOf types.str;
      description = "Filesystem paths to back up.";
    };

    excludeFile = mkOption {
      type = types.path;
      description = ''
        Plain-text file of restic exclude patterns (one per line), read
        directly from disk at backup time -- not copied into the Nix store,
        so it can be edited without a rebuild.
      '';
    };

    environmentFile = mkOption {
      type = types.path;
      default = config.age.secrets.bt_backup_env.path;
      defaultText = literalExpression "config.age.secrets.bt_backup_env.path";
      description = ''
        EnvironmentFile providing RESTIC_PASSWORD, B2_ACCOUNT_ID and
        B2_ACCOUNT_KEY. Decrypted via agenix; the encrypted secret itself
        lives in the private nixfigs-secrets repo, not here.
      '';
    };

    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* 0/2:00:00";
      description = "systemd.time(7) calendar spec. Defaults to every 2 hours.";
    };

    randomizedDelaySec = mkOption {
      type = types.str;
      default = "15m";
      description = ''
        Random jitter added before each run, so MJOLNIR, DEUSEX and
        MORPHEUS don't all hit B2 at the same moment.
      '';
    };

    pruneOpts = mkOption {
      type = types.listOf types.str;
      default = [
        "--keep-hourly 24"
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
      description = "restic forget --prune retention policy, run after each backup.";
    };
  };

  config = mkIf cfg.enable {
    services.restic.backups.b2 = {
      repository = "b2:${cfg.bucket}:${cfg.repositoryPath}";
      inherit (cfg) paths;
      inherit (cfg) environmentFile;
      initialize = true;
      inhibitsSleep = true;
      extraBackupArgs = [
        "--exclude-file=${cfg.excludeFile}"
        "--exclude-caches"
      ];
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        RandomizedDelaySec = cfg.randomizedDelaySec;
        Persistent = false;
      };
      inherit (cfg) pruneOpts;
      runCheck = true;
      checkOpts = ["--read-data-subset=5%"];
    };

    # The restic module doesn't expose unitConfig knobs directly, so the
    # AC-power and network-online gating is layered on top of the
    # generated restic-backups-b2.service unit here.
    systemd.services.restic-backups-b2.unitConfig = {
      ConditionACPower = true;
      ConditionPathExists = "/tmp/network-online.flag";
    };

    # The restic module names its unit "restic-backups-b2" after the
    # services.restic.backups.b2 job above, and only wires it to a timer
    # (no wantedBy on the service itself) -- so `systemctl start
    # restic-backups-b2.service` already works standalone. These just wrap
    # that plus a status/monitoring view.
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "b2-backup-now" ''
        set -euo pipefail
        echo "Triggering restic-backups-b2.service (blocks until it finishes)..."
        ${lib.getExe' pkgs.systemd "systemctl"} start --wait restic-backups-b2.service
        ${lib.getExe' pkgs.systemd "systemctl"} status --no-pager restic-backups-b2.service
      '')
      (pkgs.writeShellScriptBin "b2-backup-status" ''
        set -euo pipefail
        echo "=== Last run ==="
        ${lib.getExe' pkgs.systemd "systemctl"} status --no-pager restic-backups-b2.service || true
        echo
        echo "=== Next scheduled run ==="
        ${lib.getExe' pkgs.systemd "systemctl"} list-timers restic-backups-b2.timer --no-pager
        echo
        echo "=== Recent log ==="
        ${lib.getExe' pkgs.systemd "journalctl"} -u restic-backups-b2.service -n 50 --no-pager
        echo
        echo "=== Latest snapshots ==="
        restic-b2 snapshots --latest 5
      '')
    ];
  };
}
