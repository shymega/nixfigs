# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

{
  age = {
    identityPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/persist/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      postfix_sasl_passwd = {
        file = ./postfix_sasl_passwd.age;
        group = "users";
        mode = "0640";
      };
      postfix_sender_relay = {
        file = ./postfix_sender_relay.age;
        group = "users";
        mode = "0640";
      };
      dzrodriguez = {
        file = ./dzrodriguez.age;
        group = "users";
        mode = "0640";
      };
      geoclue_url = {
        file = ./geoclue_url.age;
        group = "users";
        mode = "0640";
      };
      zerotier_networks = {
        file = ./zerotier_networks.age;
        group = "users";
        mode = "0640";
      };
      wireless = {
        file = ./wireless.age;
        group = "users";
        mode = "0640";
      };
      synapse_secret = {
        file = ./synapse_secret.age;
        owner = "224";
        group = "224";
        mode = "0640";
      };
      cloudflare_dns_token = {
        file = ./cloudflare_dns_token.age;
        group = "users";
        mode = "0640";
      };
      nixbuild_ssh_pub_key = {
        file = ./nixbuild_ssh_pub_key.age;
        group = "users";
        mode = "0600";
      };
      nixbuild_ssh_priv_key = {
        file = ./nixbuild_ssh_priv_key.age;
        group = "users";
        mode = "0600";
      };
      matrix-sliding-sync-env = {
        file = ./matrix-sliding-sync-env.age;
        group = "nogroup";
        mode = "0640";
      };
      nix_conf_access_tokens = {
        file = ./nix_conf_access_tokens.age;
        group = "users";
        mode = "0640";
      };
      "restic_env" = {
        file = ./restic/env.age;
        group = "users";
        mode = "0640";
      };
      "restic_repo" = {
        file = ./restic/repo.age;
        group = "users";
        mode = "0640";
      };
      "restic_pw" = {
        file = ./restic/pw.age;
        group = "users";
        mode = "0640";
      };

    };
  };
}
