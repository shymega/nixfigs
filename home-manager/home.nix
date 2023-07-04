{ inputs, config, lib, pkgs, ... }:

let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    config = { allowUnfree = true; };
    system = pkgs.system;
  };
in
{
  imports = [ ./network-targets.nix ./programs/rofi.nix ];

  home.username = "dzrodriguez";
  home.stateVersion = "23.05";

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
    dunst.enable = true;
    mpd-discord-rpc.enable = true;
    mpris-proxy.enable = true;
    mpdris2.enable = true;
    mpd = {
      enable = true;
      musicDirectory = "/home/dzrodriguez/Multimedia/Music/";
      extraConfig = ''
        audio_output {
            type "pipewire"
            name "My PipeWire Output"
        }
      '';
    };
    # kanshi.enable = true;
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
      package = nixpkgs-unstable.vscode.fhs;
    };
    direnv.enable = true;
    home-manager.enable = true;
    fish.enable = true;
  };

  home.packages = with nixpkgs-unstable; [
    ack
    android-tools
    asciinema
    atuin
    awscli2
    aws-sam-cli
    azure-cli
    bat
    bitwarden
    brightnessctl
    cocogitto
    coreutils
    curl
    docker-compose
    dogdns
    encfs
    exa
    expect
    file
    fuse
    fzf
    genact
    gh
    gitkraken
    gnumake
    google-cloud-sdk
    gpicview
    hadolint
    hercules
    httpie
    hub
    itd
    jq
    just
    jdk17
    maven
    minikube
    minishift
    mkcert
    mpc-cli
    mpv
    mupdf
    ncmpcpp
    networkmanagerapplet
    nixfmt
    nodejs
    p7zip
    pass
    pulseaudio
    pavucontrol
    podman-compose
    pre-commit
    q
    ranger
    rclone
    reuse
    ripgrep
    rustup
    scrcpy
    silver-searcher
    starship
    steam-run
    step-cli
    stow
    texlive.combined.scheme-full
    tmuxp
    unzip
    virt-manager
    wget
    yt-dlp
    zathura
    zip
    zoxide
  ];

  news.display = "silent";
}
