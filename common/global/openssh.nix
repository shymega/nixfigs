{ outputs, lib, config, ... }:

let inherit (config.networking) hostName;
in {
  services.openssh = {
    enable = true;
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;
}
