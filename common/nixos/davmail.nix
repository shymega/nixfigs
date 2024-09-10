# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

{
  services.davmail = {
    enable = true;
    url = "https://outlook.office365.com/EWS/Exchange.asmx";
    config = {
      davmail = {
        allowRemote = false;
        imapPort = 11143;
        bindAddress = "127.0.0.1";
        smtpPort = 0;
        calDavPort = 0;
        ldapPort = 0;
        popPort = 0;
      };
    };
  };
}
