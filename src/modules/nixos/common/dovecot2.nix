# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
{
  config,
  lib,
  ...
}: let
  userHome = "/home/dzrodriguez";
in {
  services.dovecot2 = {
    enable = true;
    enablePAM = false;
    settings = {
      protocols = {
        imap = true;
        pop3 = false;
      };
      dovecot_config_version = config.services.dovecot2.package.version;
      dovecot_storage_version = config.services.dovecot2.package.version;
      mail_home = "${userHome}/.mail/%{user | domain | lower}/%{user | lower}";
      mail_path = "~/";
      mail_inbox_path = "~/INBOX";
      mailbox_list_layout = "fs";
      mail_driver = "maildir";
      listen = "127.0.0.1, ::1${lib.optionalString (config.networking.hostName == "delta-zero") ", 100.70.185.78"}";
      mail_uid = "1000";
      mail_gid = "100";

      "namespace inbox" = {
        inbox = "yes";

        "mailbox Drafts" = {
          special_use = "\\Drafts";
          auto = "subscribe";
        };

        "mailbox \"Spam\"" = {
          special_use = "\\Junk";
        };

        "mailbox \"Sent\"" = {
          special_use = "\\Sent";
          auto = "subscribe";
        };

        "mailbox \"Trash\"" = {
          special_use = "\\Trash";
          auto = "subscribe";
        };

        prefix = "";
        separator = "/";
      };

      "userdb static" = {
        fields = {
          allow_all_users = "yes";
          uid = config.services.dovecot2.settings.mail_uid;
          gid = config.services.dovecot2.settings.mail_gid;
          home = config.services.dovecot2.settings.mail_home;
        };
      };

      "passdb static" = {
        fields = {
          nopassword = "yes";
        };
      };

      "sieve_script personal" = {
        type = "personal";
        path = "${config.services.dovecot2.settings.mail_home}/scripts";
        active_path = "${config.services.dovecot2.settings.mail_home}/active-script.sieve";
      };

      maildir_broken_filename_sizes = "yes";
    };
  };
}
