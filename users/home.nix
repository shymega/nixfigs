# SPDX-FileCopyrightText: 2023 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs, config, ... }:
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
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      atuin
      bat
      bc
      brightnessctl
      cachix
      cocogitto
      comma
      coreutils-full
      curl
      darkman
      dateutils
      dex
      diesel-cli
      distrobox
      dogdns
      encfs
      exercism
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
      just
      kodi-wayland
      lapce
      lazygit
      m4
      maven
      minikube
      minishift
      mkcert
      mpc-cli
      mpv
      mupdf
      ncmpcpp
      neomutt
      nixpkgs-fmt
      nodejs
      notmuch
      opentofu
      p7zip
      pass
      pavucontrol
      podman-compose
      poppler_utils
      pre-commit
      python3Full
      python3Packages.bugwarrior
      python3Packages.pip
      python3Packages.pipx
      python3Packages.virtualenv
      q
      ranger
      rclone
      reuse
      ripgrep
      rustup
      sbcl
      scrcpy
      speedtest-go
      starship
      statix
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
      wget
      xsv
      yt-dlp
      zathura
      zip
      zoxide
    ] ++ (with pkgs; [
      aws-sam-cli
      awscli2
      azure-cli
      google-cloud-sdk
      isync-patched
      weechatWithMyPlugins
    ]) ++ (lib.optionals pkgs.stdenv.isx86_64 (with pkgs.unstable; [
      bitwarden
      gitkraken
      jetbrains.clion
      jetbrains.datagrip
      jetbrains.gateway
      jetbrains.goland
      jetbrains.idea-ultimate
      jetbrains.pycharm-professional
      jetbrains.rider
      jetbrains.rust-rover
      jetbrains.webstorm
      steam-run
    ]));
  };

  services = {
    keybase.enable = true;
    gpg-agent = {
      enable = true;
      pinentryFlavor = "gtk2";
      enableScDaemon = false;
      enableSshSupport = false;
      enableExtraSocket = false;
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
      enable = true;
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
          server = "inthe.am:53589";
        };
      };
    };
  };
  news.display = "silent";
  systemd.user.tmpfiles.rules = [ "L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0" ];
}
