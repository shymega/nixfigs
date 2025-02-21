# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, ... }:
let
  userHome = if config.networking.hostName == "MORPHEUS-LINUX" then config.users.users."dominic.rodriguez".home else config.users.users.dzrodriguez.home;
in
{
  services.dovecot2 = {
    enable = true;
    user = "dzrodriguez";
    group = "users";
    mailLocation =
      "maildir:${config.users.users.dzrodriguez.home}/.mail/%d/%u/:LAYOUT=fs:INBOX=${userHome}/.mail/%d/%u/INBOX";
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

          mailbox "Junk Email" {
            special_use = \Junk
          }

          mailbox "Sent Items" {
            special_use = \Sent
            auto = subscribe
          }

          mailbox "Deleted Items" {
            special_use = \Trash
            auto = subscribe
          }

          prefix =
          separator = /
      }

      passdb {
          driver = static
          args = nopassword
      }
    '';
  };
}

