{ inputs, config, lib, pkgs, ... }:

{
  imports = [ ./network-targets.nix ./programs/rofi.nix ];

  home.username = "dzrodriguez";

  home.stateVersion = "22.11";

  services = {
    keybase.enable = true;
    gpg-agent.enable = true;

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
    xclip
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
    polkit_gnome
    networkmanagerapplet
    mpd-mpris
    playerctl
    mpdris2
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
    azure-cli
    awscli2
    google-cloud-sdk
    p7zip
    nodejs
    stow
    gammastep
    corefonts
    atuin
    exa
    bat
    genact
    just
    starship
    zoxide
    pavucontrol
  ];

  news.display = "silent";
}
