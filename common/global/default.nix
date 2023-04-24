{ lib, inputs, ... }: {
  imports = [
    ./bluetooth.nix
    ./common_env.nix
    ./docker.nix
    ./fish.nix
    ./fonts.nix
    ./impermanence.nix
    ./keychron.nix
    ./locale.nix
    ./hw.nix
    ./networking.nix
    ./nix.nix
    ./openssh.nix
    # ./sops.nix
    ./podman.nix
    ./sound.nix
    ./steam-hardware.nix
    ./systemd-initrd.nix
    ./xdg.nix

    ./custom-systemd-units
  ];
}
