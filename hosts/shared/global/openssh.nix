{ config, ... }:
{
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = true;
    };
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.enableSSHAgentAuth = true;
}
