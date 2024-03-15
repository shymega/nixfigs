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
in
{
  imports = [ ./network-targets.nix ./programs/rofi.nix ];

  nixpkgs = {
    config = {
      allowUnfreePredicate = _: true;
      allowBrokenPredicate = _: true;
      allowInsecurePredicate = _: true;
    };
  };

  home = {
    username = "dzrodriguez";
    homeDirectory = homePrefix + "/${config.home.username}";
    enableNixpkgsReleaseCheck = true;
    stateVersion = "23.11";
    packages = with pkgs.unstable; [
      android-tools
      asciinema
      bat
      bc
      brightnessctl
      cachix
      cachix
      cocogitto
      comma
      curl
      darkman
      dateutils
      dex
      diesel-cli
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
      maven
      mkcert
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
      poppler_utils
      pre-commit
      python3Full
      python3Packages.pipx
      python3Packages.virtualenv
      q
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
      unrar
      unzip
      vagrant
      virt-manager
      w3m
      wget
      xsv
      yt-dlp
      zathura
      zellij
      zip
      zoxide
    ] ++ [
      inputs.devenv.packages.${pkgs.system}.devenv
    ] ++ (lib.optionals (hostname == "NEO-LINUX")
      pkgs.asfp.android-studio-for-platform)
    ++ (with pkgs.unstable; [
      (vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
      })
    ]) ++ (with pkgs; [
      atuin
      aws-sam-cli
      awscli2
      azure-cli
      gitkraken
      google-cloud-sdk
      isync-patched
      weechatWithMyPlugins
      yubikey-manager-qt
      yubioath-flutter
    ]) ++ (lib.optionals pkgs.stdenv.isx86_64 (with pkgs.unstable.jetbrains; [
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
      pinentryFlavor = "gtk2";
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
    emacs = {
      enable = true;
      package = pkgs.emacs28NativeComp;
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

  age = {
    identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
  };

  programs = {
    rbw.enable = true;
    git.lfs.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
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
  systemd.user.tmpfiles.rules = [ "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0" ];
}
