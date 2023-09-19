{ config, ... }: {
  services.dovecot2 = {
    enable = true;
    user = "dzrodriguez";
    group = "users";
    ## TODO: Move mailLocation to /var.
    mailLocation =
      "maildir:${config.users.users.dzrodriguez.home}/.mail/%d/%u/:LAYOUT=fs:INBOX=${config.users.users.dzrodriguez.home}/.mail/%d/%u/INBOX";
    enablePAM = false;
    enableImap = true;
    enablePop3 = false;
    extraConfig = ''
            listen = 127.0.0.1, ::1
            mail_uid = 1000
            mail_gid = 100

            namespace inbox {
                inbox = yes
                location =

                mailbox Drafts {
                  special_use = \Drafts
                  auto = subscribe
                }

                mailbox Spam {
                  special_use = \Junk
                }

                mailbox Sent {
                  special_use = \Sent
                  auto = subscribe
                }

                mailbox Trash {
                  special_use = \Trash
                  auto = subscribe
                }

                prefix =
                separator = .
              }

              passdb {
                  driver = static
      	    args = nopassword
              }
    '';
  };
}

