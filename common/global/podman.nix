{ lib, ... }: {
  virtualisation.podman = { enable = false; };

  environment.persistence = {
    "/persist".directories = [ "/var/lib/containers" ];
  };
}
