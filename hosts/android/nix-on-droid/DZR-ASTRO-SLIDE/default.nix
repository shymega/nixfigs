{ self, inputs, pkgs, config, ... }: {
  environment.packages = with pkgs; [
    vim
    neovim
    nano

    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
  ];
}
