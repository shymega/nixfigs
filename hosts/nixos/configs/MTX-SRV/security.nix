{ config, ... }:
let
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
  adminEmail = "shymega2011@gmail.com";
in
{
  security.acme = {
    defaults = {
      email = adminEmail;
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_KEY_FILE" = config.age.secrets.cloudflare_dns_token.path;
      };
    };
    certs."${fqdn}" = {
      group = "nginx";
    };
    acceptTerms = true;
  };
}
