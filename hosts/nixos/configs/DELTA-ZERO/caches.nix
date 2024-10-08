# SPDX-FileCopyrightText: 2024 Various Authors <generic@example.com>
#
# SPDX-License-Identifier: GPL-3.0-only

{
  gc_min_interval = [
    "15m"
    "30m"
    "60m"
  ];
  gc_thresholds = [
    10000
    5000
    2500
  ];
  event_cache_size = "12000K"; # defaults to 10K
  caches = {
    global_factor = 500000.0;
    cache_entry_ttl = "24h";
    expire_caches = true;
    sync_response_cache_duration = "900s";
    cache_autotuning = {
      max_cache_memory_usage = "65536M";
      target_cache_memory_usage = "32768M";
      min_cache_ttl = "6h";
    };
  };
}
