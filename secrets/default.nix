{ config, ... }:
{
  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      postfix_sasl_passwd.file = ./postfix_sasl_passwd.age;
      postfix_sender_relay.file = ./postfix_sender_relay.age;
      user_dzrodriguez.file = ./user_dzrodriguez.age;
    };
  };
}
