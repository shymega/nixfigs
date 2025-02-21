# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ inputs, pkgs, config, hostname, ... }:
let
  inherit (pkgs.stdenvNoCC) isDarwin;
  homePrefix =
    if isDarwin then
      "/Users"
    else
      "/home";
  homeDirectory = homePrefix + "/${config.home.username}";
in
{
  imports = [
    ./network-targets.nix
    ./secrets_user.nix
    ./programs/rofi.nix
    inputs.nix-doom-emacs-unstraightened.hmModule
  ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = _: true;
      allowBrokenPredicate = _: true;
      allowInsecurePredicate = _: true;
    };
  };

  home = {
    username = "dzrodriguez";
    inherit homeDirectory;
    enableNixpkgsReleaseCheck = true;
    stateVersion = "24.05";
    packages = with pkgs.unstable; [
      android-tools
      ansible
      b4
      bat
      bc
      beeper
      brightnessctl
      cachix
      cloudflared
      cocogitto
      curl
      darkman
      dateutils
      devenv
      dex
      diesel-cli
      difftastic
      distrobox
      dogdns
      encfs
      expect
      eza
      firefox
      fuse
      fzf
      gh
      gnumake
      google-chrome
      gpicview
      httpie
      hub
      inetutils
      itd
      jdk17
      jq
      khal
      khard
      leafnode
      maven
      mkcert
      moneydance
      mpc-cli
      mpv
      mupdf
      ncmpcpp
      neomutt
      nixpkgs-fmt
      nodejs
      notmuch
      p7zip
      parallel
      pass
      pavucontrol
      poetry
      poppler_utils
      pre-commit
      public-inbox
      python3Full
      python3Packages.pip
      python3Packages.pipx
      python3Packages.virtualenv
      q
      qemu_full
      ranger
      rclone
      reuse
      ripgrep
      rustup
      scrcpy
      speedtest-go
      starship
      statix
      step-cli
      stow
      texlive.combined.scheme-full
      timewarrior
      tmuxp
      unrar
      unzip
      vagrant
      vdirsyncer
      virt-manager
      virtiofsd
      w3m
      wezterm
      wget
      xsv
      yt-dlp
      zathura
      zellij
      zip
      zoxide
    ] ++ (with pkgs.lib; optionals (hostname == "NEO-LINUX") [
      pkgs.android-studio
      pkgs.unstable.android-studio-for-platform
    ]) ++ [ inputs.agenix.packages.${pkgs.system}.default ]
    ++ (with pkgs; [
      aws-sam-cli
      awscli2
      azure-cli
      gitkraken
      google-cloud-sdk
      isync-patched
      lutris
      offlineimap
      protontricks
      protonup-qt
      steamcmd
      totp
      weechatWithMyPlugins
      wineWowPackages.stable
      winetricks
      yubikey-manager-qt
      yubioath-flutter
    ]) ++ (with pkgs; lib.optionals stdenv.isx86_64 (with pkgs.unstable.jetbrains; [
      clion
      datagrip
      gateway
      goland
      idea-ultimate
      phpstorm
      pycharm-professional
      rider
      ruby-mine
      rust-rover
      webstorm
    ]));
  };

  services = {
    keybase.enable = true;
    gpg-agent = {
      enable = true;
      pinentryPackage = with pkgs; lib.mkForce pinentry-gtk2;
      enableScDaemon = true;
      enableSshSupport = false;
      enableExtraSocket = true;
      defaultCacheTtl = 43200;
      maxCacheTtl = 43200;
    };
    gnome-keyring = {
      enable = true;
      components = [ "secrets" ];
    };
    dunst.enable = true;
    mpd-discord-rpc.enable = false;
    mpris-proxy.enable = true;
    mpdris2.enable = true;
    emacs = {
      enable = true;
      client.enable = true;
      startWithUserSession = true;
      socketActivation.enable = true;
      package = pkgs.emacs29-pgtk;
    };
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
    gammastep = {
      enable = true;
      provider = "geoclue2";
    };
    redshift = {
      enable = false;
      provider = "geoclue2";
    };
  };

  programs = {
    atuin = {
      enable = true;
      settings = {
        key_path = config.age.secrets.atuin_key.path;
        sync_address = "https://shynet-atuin-server.fly.dev";
        auto_sync = false;
        dialect = "uk";
        secrets_filter = true;
        enter_accept = false;
        workspaces = true;
        sync = {
          records = true;
        };
        daemon = {
          enabled = true;
          systemd_socket = true;
        };
      };
    };
    nix-index-database.comma.enable = true;
    nix-index.enable = true;
    rbw.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
    };
    git = {
      enable = true;
      lfs.enable = true;
      extraConfig = {
        #        gpg.format = "ssh";
        #        "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        #        commit.gpgsign = true;
      };
      aliases = {
        aa = "add --all";
        amend = "commit --amend";
        br = "branch";
        checkpoint = "stash --include-untracked; stash apply";
        cp = "checkpoint";
        cm = "commit -m";
        co = "checkout";
        dc = "diff --cached";
        dft = "difftool";
        hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
        lg = "log --graph --branches --oneline --decorate --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C";
        loc = "!git diff --stat `git hash-object -t tree /dev/null` | tail -1 | cut -d' ' -f5";
        st = "status -sb";
        sum = "log --oneline --no-merges";
        unstage = "reset --soft HEAD";
        revert = "revert --no-edit";
        squash-all = "!f(){ git reset $(git commit-tree HEAD^{tree} -m 'A new start');};f";
      };
    };
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    home-manager.enable = true;
    fish.enable = true;
    emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };
    taskwarrior = {
      enable = true;
      config = {
        report = {
          minimal.filter = "status:pending";
          active.columns = [ "id" "start" "entry.age" "priority" "project" "due" "description" ];
          active.labels = [ "ID" "Started" "Age" "Priority" "Project" "Due" "Description" ];
        };
      };
    };
  };
  news.display = "silent";

  systemd.user =
    let
      atuinDataDir = "${homeDirectory}/.local/share/atuin";
      atuinSocket = "${atuinDataDir}/atuin.sock";
      atuinDaemonConfig = {
        Description = "Atuin - Magical Shell History Daemon";
        ConditionPathIsDirectory = atuinDataDir;
        ConditionPathExists = "${homeDirectory}/.config/atuin/config.toml";
      };
      atuinSyncTimerConfig = {
        Description = "Atuin - Magical Shell History Syncer";
        ConditionPathIsDirectory = atuinDataDir;
        ConditionPathExists = "${homeDirectory}/.config/atuin/config.toml";
      };
    in
    {
      tmpfiles.rules = [ "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0" ];
      sockets.atuin-daemon = {
        Unit = atuinDaemonConfig;
        Install.WantedBy = [ "default.target" ];
        Socket = {
          ListenStream = atuinSocket;
          Accept = false;
          RemoveOnStop = true;
          SocketMode = [ "0600" ];
        };
      };
      services = {
        atuin-daemon = {
          Unit = atuinDaemonConfig // { Requires = [ "atuin-daemon.socket" ]; };
          Service = {
            ExecStart = "${pkgs.unstable.atuin}/bin/atuin daemon";
          };
        };
        atuin-sync = {
          Unit = atuinSyncTimerConfig;
          Service = {
            ExecStart = "${pkgs.unstable.atuin}/bin/atuin daemon";
          };
        };
      };
      timers.atuin-sync = {
        Unit = atuinSyncTimerConfig;
        Timer = {
          OnBootSec = "1min";
          OnCalendar = "OnCalendar=*:0/15";
        };
      };
    };
}
