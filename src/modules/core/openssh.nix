# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{lib, ...}: {
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = lib.mkForce false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = lib.mkForce false;
    };
  };

  # Passwordless sudo when SSH'ing with keys
  security.pam.sshAgentAuth.enable = true;
}
