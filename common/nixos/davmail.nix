{
  services.davmail = {
    enable = true;
    url = "https://outlook.office365.com/EWS/Exchange.asmx";
    config = {
      davmail.allowRemote = false;
      davmail.imapPort = 11143;
      davmail.bindAddress = "127.0.0.1";
      davmail.smtpPort = 0;
      davmail.calDavPort = 0;
      davmail.ldapPort = 0;
      davmail.popPort = 0;
    };
  };
}
