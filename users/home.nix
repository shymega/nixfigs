{ inputs, pkgs, config, ... }: {
  imports = [ ./network-targets.nix ./programs/rofi.nix ];

  home = {
    username = "dzrodriguez";
    homeDirectory = "/home/${config.home.username}";
    enableNixpkgsReleaseCheck = true;
    stateVersion = "23.05";
    packages = with pkgs.unstable; [
      ack
      aerc
      alot
      android-tools
      asciinema
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      atuin
      aws-sam-cli
      awscli2
      bat
      bc
      bitwarden
      brightnessctl
      cocogitto
      coreutils
      curl
      darkman
      dateutils
      dex
      diesel-cli
      distrobox
      docker-compose
      dogdns
      encfs
      expect
      eza
      file
      freerdp
      fuse
      fzf
      genact
      gh
      gitkraken
      gnumake
      goimapnotify
      google-chrome
      google-cloud-sdk
      gpicview
      hercules
      httpie
      hub
      inetutils
      isync
      itd
      jdk17
      jetbrains.clion
      jetbrains.datagrip
      jetbrains.gateway
      jetbrains.goland
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      jetbrains.rider
      jetbrains.webstorm
      jq
      just
      kodi-wayland
      lazygit
      m4
      maven
      minikube
      minishift
      mkcert
      mpc-cli
      mpv-unwrapped
      mupdf
      ncmpcpp
      neomutt
      nixfmt
      nixpkgs-fmt
      nodejs
      notmuch
      p7zip
      pass
      pavucontrol
      podman-compose
      poppler_utils
      pre-commit
      python3Full
      python3Packages.aiohttp
      python3Packages.virtualenv
      q
      ranger
      rclone
      reuse
      ripgrep
      rustup
      sbcl
      scrcpy
      silver-searcher
      speedtest-go
      starship
      statix
      steam-run
      step-cli
      stow
      texlive.combined.scheme-full
      thunderbird
      timewarrior
      tmuxp
      unrar
      unzip
      vagrant
      virt-manager
      w3m
      weechatWithMyPlugins
      wget
      xsv
      yt-dlp
      zathura
      zip
      zoxide
    ];
  };

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
    dunst.enable = true;
    mpd-discord-rpc.enable = true;
    mpris-proxy.enable = true;
    mpdris2.enable = true;
    mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Multimedia/Music/";
      extraConfig = ''
        audio_output {
            type "pipewire"
            name "PipeWire Output"
        }
      '';
    };
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

  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
    ];
    secrets = {
      taskwarrior_sync_ca.file = ../secrets/taskwarrior_sync_ca.age;
      taskwarrior_sync_cert.file = ../secrets/taskwarrior_sync_cert.age;
      taskwarrior_sync_key.file = ../secrets/taskwarrior_sync_key.age;
      taskwarrior_sync_cred.file = ../secrets/taskwarrior_sync_cred.age;
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
    doom-emacs = {
      enable = true;
      doomPrivateDir = ./doom.d;
    };
    taskwarrior = {
      enable = true;
      config = {
        confirmation = false;
        report = {
          minimal.filter = "status:pending";
          active.columns = [ "id" "start" "entry.age" "priority" "project" "due" "description" ];
          active.labels = [ "ID" "Started" "Age" "Priority" "Project" "Due" "Description" ];
        };
        taskd = {
          certificate = config.age.secrets.taskwarrior_sync_cert.path;
          key = config.age.secrets.taskwarrior_sync_key.path;
          ca = config.age.secrets.taskwarrior_sync_ca.path;
          server = "inthe.am:53589";
          credentials = config.age.secrets.taskwarrior_sync_cred.path;
        };
      };
    };
  };
  news.display = "silent";
}
