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
      package = pkgs.vscode.fhs;
    };
    direnv.enable = true;
    home-manager.enable = true;
    fish.enable = true;
  };

  home.packages = with pkgs; [
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
    minikube
    minishift
    mkcert
    modem-manager-gui
    mpc-cli
    mpv
    mupdf
    ncmpcpp
    networkmanagerapplet
    nixfmt
    nodejs
    p7zip
    pass
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
