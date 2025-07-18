# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  config,
  pkgs,
  ...
}: {
  services.postfix = {
    enable = true;
    enableSmtp = true;
    enableSubmission = false;
    enableSubmissions = false;
    setSendmail = true;
    enableHeaderChecks = true;
    headerChecks = [
      {
        pattern = "/^/";
        action = "HOLD";
      }
      {
        pattern = "/^X-Delay*:/";
        action = "IGNORE";
      }
    ];
    extraAliases = ''
      postmaster: root
      root: dzodriguez
      root: noreply+${config.networking.hostName}@rodriguez.org.uk
    '';
    extraHeaderChecks = ''
      /^Date:/i PREPEND x-ms-reactions: disallow
    '';
    mapFiles."sasl_passwd" = config.age.secrets.postfix_sasl_passwd.path;
    mapFiles."sender_relay" = config.age.secrets.postfix_sender_relay.path;
    mapFiles."generic" = pkgs.writeText "postfix_generic" ''
      root@localdomain dzrodriguez@rodriguez.org.uk
      root@rodriguez.org.uk dominic.rodriguez@rodriguez.org.uk
      root dominic.rodriguez@rodriguez.org.uk
      @localdomain.local dominic.rodriguez@rodriguez.org.uk
      @rodriguez.org.uk dominic.rodriguez@rodriguez.org.uk
    '';
    relayDomains = [
      "rodriguez.org.uk"
      "shymega.org.uk"
    ];
    extraConfig = ''
      smtp_generic_maps = hash:/etc/postfix/generic
    '';
    networks = [
      "127.0.0.0/8"
      "[::1]/128"
    ];
    config = {
      smtp_sender_dependent_authentication = "yes";
      smtp_sasl_mechanism_filter = "plain";
      sender_dependent_default_transport_maps = "hash:/etc/postfix/sender_relay";
      smtp_sasl_auth_enable = "yes";
      smtp_tls_security_level = "may";
      smtp_sasl_password_maps = "hash:/etc/postfix/sasl_passwd";
      smtp_tls_mandatory_protocols = "!SSLv2, !TLSv1, !TLSv1.1";
      smtp_sasl_security_options = "noanonymous";
      smtp_use_tls = "yes";
    };
  };
}
