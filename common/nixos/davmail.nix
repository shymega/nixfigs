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
