{ ... }: {
  imports = [
    ./aspell.nix
    ./common_env.nix
    ./containers.nix
    ./fish.nix
    ./fonts.nix
    ./locale.nix
    ./nix.nix
    ./openssh.nix
    ./tmux.nix
  ];
}
