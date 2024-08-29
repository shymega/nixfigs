{ pkgs, ... }:
{
  services = {
    postgresql = {
      enable = true;
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
      '';
      ensureDatabases = [ "mautrix_slack" "mautrix_whatsapp" "mautrix_meta_facebook" "mautrix_meta_instagram" "mautrix_meta_messenger" "mautrix_telegram" "matrix_synapse_syncv3" ];

      settings = {
        # https://pgconfigurator.cybertec.at/
        max_connections = 1850;
        superuser_reserved_connections = 3;

        shared_buffers = "2GB";
        work_mem = "16GB";
        maintenance_work_mem = "8GB";
        huge_pages = "try";
        effective_cache_size = "64GB"; # was 22
        effective_io_concurrency = 100;
        random_page_cost = 1.1;

        # can use this to view stats: SELECT query, total_time, calls, rows FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;
        shared_preload_libraries = "pg_stat_statements";
        track_io_timing = "on";
        track_functions = "pl";
        "pg_stat_statements.max" = "10000"; # additional
        "pg_stat_statements.track" = "all"; # additional

        wal_level = "replica";
        max_wal_senders = 0;
        synchronous_commit = "off"; # was ond3

        checkpoint_timeout = "15min";
        checkpoint_completion_target = "0.9";
        max_wal_size = "2GB";
        min_wal_size = "1GB";

        wal_compression = "on";
        wal_buffers = "-1";
        wal_writer_delay = "200ms";
        wal_writer_flush_after = "1MB";
        #checkpoint_segments = "64"; # additional
        default_statistics_target = "250"; # additional

        bgwriter_delay = "200ms";
        bgwriter_lru_maxpages = "100";
        bgwriter_lru_multiplier = "2.0";
        bgwriter_flush_after = "0";

        max_worker_processes = "32"; # was 14
        max_parallel_workers_per_gather = "16"; # was 7
        max_parallel_maintenance_workers = "16"; # was 7
        max_parallel_workers = "32"; # was 14
        parallel_leader_participation = "on";

        enable_partitionwise_join = "on";
        enable_partitionwise_aggregate = "on";
        jit = "on";
        max_slot_wal_keep_size = "1GB";
        track_wal_io_timing = "on";
        maintenance_io_concurrency = "4";
        wal_recycle = "on";
      };
    };
  };
}
