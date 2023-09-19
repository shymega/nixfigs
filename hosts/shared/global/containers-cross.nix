{ inputs, outputs, config, ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
}
