{ config, ... }:
let
  adminEmail = "shymega2011@gmail.com";
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = adminEmail;
      dnsProvider = "cloudflare";
      credentialFiles = {
        CLOUDFLARE_API_KEY_FILE = config.age.secrets.cloudflare_dns_token.path;
      };
    };
  };
}
