{ inputs, config, lib, ... }:

let pkgs = import inputs.nixpkgs-unstable { config = { allowUnfree = true; }; };
in {
  imports = [ ./network-targets.nix ./programs/rofi.nix ];

  home.username = "dzrodriguez";
  home.stateVersion = "22.11";

  services = {
    keybase.enable = true;
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gnome3";
      enableExtraSocket = true;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
    };
    gnome-keyring = {
      enable = true;
      components = [ "secrets" ];
    };
    network-manager-applet.enable = true;
    #mako.enable = true;
    dunst.enable = true;
    #    mpd-discord-rpc.enable = true;
    #    mpris-proxy.enable = true;
    #    mpdris2.enable = true;
    #    kanshi.enable = true;
    emacs.enable = true;
    gammastep = {
      enable = true;
      provider = "geoclue2";
    };
    redshift = {
      enable = true;
      provider = "geoclue2";
    };
  };

  programs = {
    rbw.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
    };
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
    direnv.enable = true;
    home-manager.enable = true;
  };

  home.packages = with pkgs; [
    pavucontrol
    fzf
    jq
    wget
    curl
    zip
    virt-manager
    unzip
    tmuxp
    docker-compose
    hub
    gh
    mpv
    brightnessctl
    ncmpcpp
    bitwarden
    networkmanagerapplet
    gpicview
    expect
    pass
    rustup
    zathura
    mupdf
    encfs
    fuse
    gnumake
    scrcpy
    ranger
    mpc-cli
    steam-run
    podman-compose
    gitkraken
    itd
    p7zip
    stow
    q
    step-cli
    mkcert
    minishift
    minikube
    rclone
    atuin
    texlive.combined.scheme-full
    exa
    httpie
    bat
    genact
    just
    starship
    zoxide
    ripgrep
    ack
    silver-searcher
  ];

  news.display = "silent";
}
