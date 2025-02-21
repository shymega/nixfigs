{
  rc_message = {
    per_second = 1000;
    burst_count = 1000;
  };
  rc_login = {
    address = {
      per_second = 1000;
      burst_count = 1000;
    };
    account = {
      per_second = 1000;
      burst_count = 1000;
    };
    failed_attempts = {
      per_second = 0.1;
      burst_count = 3;
    };
  };
  rc_joins = {
    local = {
      per_second = 1000;
      burst_count = 1000;
    };
    remote = {
      per_second = 1000;
      burst_count = 1000;
    };
  };
  rc_joins_per_room = {
    per_second = 1000;
    burst_count = 1000;
  };
  rc_invites = {
    per_room = {
      per_second = 1000;
      burst_count = 1000;
    };
    per_user = {
      per_second = 1000;
      burst_count = 1000;
    };
    per_issuer = {
      per_second = 1000;
      burst_count = 1000;
    };
  };
  rc_federation = {
    window_size = 10;
    sleep_limit = 1000;
    sleep_delay = 100;
    reject_limit = 1000;
    concurrent = 100;
  };
  federation_rr_transactions_per_room_per_second = 1;
}
