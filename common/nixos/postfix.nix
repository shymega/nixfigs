{ config, ... }: {
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
        pattern = "/^Received:.*with ESMTPSA/";
        action = "IGNORE";
      }
      {
        pattern = "/^X-Originating-IP:/";
        action = "IGNORE";
      }
      {
        pattern = "/^X-Mailer:/";
        action = "IGNORE";
      }
      {
        pattern = "/^Received:/";
        action = "IGNORE";
      }
      {
        pattern = "/^User-Agent:/";
        action = "IGNORE";
      }
      {
        pattern = "/^X-Delay*:/";
        action = "IGNORE";
      }
    ];
    mapFiles."sasl_passwd" = config.age.secrets.postfix_sasl_passwd.path;
    mapFiles."sender_relay" = config.age.secrets.postfix_sender_relay.path;
    extraConfig = ''
      smtp_sender_dependent_authentication = yes
      sender_dependent_default_transport_maps = hash:/etc/postfix/sender_relay

      smtp_sasl_auth_enable = yes
      smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
      smtp_sasl_security_options = noanonymous
      smtp_use_tls = yes

      smtpd_sasl_auth_enable = yes
      smtpd_tls_auth_only = yes
    '';
  };
}
