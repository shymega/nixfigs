{ lib, inputs, ... }: {
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/NetworkManager"
    ];
    files = [ "/etc/machine-id" ];
  };
}
