{ lib, inputs, ... }: {
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/NetworkManager"
      "/var/lib"
      "/etc/ssh"
      "/var/lib/systemd"
      "/var/lib/nixos"
      "/var/log"
      "/srv"
    ];
    files = [ "/etc/machine-id" ];
  };
}
