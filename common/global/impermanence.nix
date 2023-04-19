{ lib, inputs, ... }: {
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/NetworkManager"
      "/var/lib"
      "/root"
    ];
    files = [ "/etc/machine-id" ];
  };
}
