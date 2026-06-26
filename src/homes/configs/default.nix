# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  inputs,
  pkgs,
  config,
  username,
  hostPlatform,
  osConfig ? null,
  self,
  lib,
  ...
}: let
  inherit (lib) isPC homePrefix;
in {
  imports = with inputs; [
    ./network-targets.nix
    ./programs/rofi.nix
    agenix.homeManagerModules.default
    nix-doom-emacs-unstraightened.hmModule
    nix-index-database.homeModules.nix-index
    _1password-shell-plugins.hmModules.default
    shypkgs-public.hmModules.${hostPlatform}.dwl
    ../../secrets/user
  ];

  home = {
    inherit username homeDirectory;
    enableNixpkgsReleaseCheck = true;
    stateVersion = "25.05";
    packages = with pkgs.unstable;
      [
        (isync-patched.override {withCyrusSaslXoauth2 = true;})
        alpaca
        android-studio-for-platform
        android-tools
        ansible
        b4
        bat
        bc
        beeper
        brightnessctl
        cloudflared
        cocogitto
        curl
        dateutils
        devenv
        dex
        diesel-cli
        difftastic
        distrobox
        dogdns
        elf2uf2-rs
        encfs
        exiftool
        expect
        eza
        firefox
        fuse
        fzf
        gnumake
        gpicview
        httpie
        hub
        hut
        imagemagick
        inetutils
        itd
        jdk17
        jq
        khal
        khard
        m4
        maven
        mkcert
        moneydance
        mpc-cli
        mupdf
        ncmpcpp
        nixpkgs-fmt
        nodejs
        notmuch
        p7zip
        parallel
        pass
        pavucontrol
        pdftk
        poetry
        poppler_utils
        pre-commit
        public-inbox
        python3Full
        python3Packages.pip
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
        tmuxp
        unrar
        unzip
        vdirsyncer
        virt-manager
        virtiofsd
        vlc
        w3m
        weechatWithMyPlugins
        wget
        xsv
        zathura
        zellij
        zenmonitor
        zip
        zoxide
      ]
      ++ [inputs.agenix.packages.${hostPlatform}.default]
      ++ (with pkgs; [
        android-studio
        aws-sam-cli
        azure-cli
        bestool
        gitkraken
        google-chrome
        google-cloud-sdk
        leafnode
        lutris
        mpv
        neomutt
        protontricks
        protonup-qt
        qemu_full
        steamcmd
        totp
        wemod-launcher
        wezterm
        wineWowPackages.stable
        winetricks
        yubikey-manager-qt
        yubioath-flutter
      ])
      ++ (
        with pkgs;
          lib.optionals isPC (
            with pkgs.unstable.jetbrains; [
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
            ]
          )
      );
  };

  services = {
    darkman = {
      enable = true;
      package = pkgs.unstable.darkman;
      settings = {
        usegeoclue = true;
      };
      darkModeScripts.gtk-theme = ''
        ${pkgs.dconf.outPath}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      '';

      lightModeScripts.gtk-theme = ''
        ${pkgs.dconf.outPath}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
      '';
    };
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
      components = ["secrets"];
    };
    dunst.enable = true;
    mpd-discord-rpc.enable = true;
    mpris-proxy.enable = true;
    mpdris2.enable = true;
    emacs = {
      enable = true;
      client.enable = true;
      startWithUserSession = true;
      socketActivation.enable = true;
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
      temperature = {
        day = 6500;
        night = 3400;
      };
      provider = "geoclue2";
    };
    redshift = {
      enable = true;
      temperature = {
        day = 6500;
        night = 3400;
      };
      provider = "geoclue2";
    };
  };

  xdg.systemDirs.data = [
    "/usr/share"
    "/var/lib/flatpak/exports/share"
    "$HOME/.local/share/flatpak/exports/share"
  ];

  programs = {
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        gh
        awscli2
        cachix
      ];
    };
    bash.enable = true;
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    dwl = {
      enable = true;
      cmd = {
        terminal = "${pkgs.wezterm}/bin/wezterm";
        editor = "${pkgs.emacs}/bin/emacslient -cq";
      };
    };
    yt-dlp.enable = true;
    htop.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        # Enable a plugin (here grc for colorized command output) from nixpkgs
        {
          name = "grc";
          inherit (pkgs.fishPlugins.grc) src;
        }
        {
          name = "done";
          inherit (pkgs.fishPlugins.done) src;
        }
        {
          name = "sponge";
          inherit (pkgs.fishPlugins.sponge) src;
        }
      ];
    };
    atuin = {
      enable = true;
      package = pkgs.unstable.atuin;
      settings = {
        key_path = config.age.secrets.atuin_key.path;
        sync_address = "https://api.atuin.sh";
        auto_sync = true;
        dialect = "uk";
        secrets_filter = true;
        enter_accept = false;
        workspaces = true;
        sync_frequency = 1800;
        sync = {
          records = true;
        };
        daemon = {
          enabled = true;
          systemd_socket = true;
          sync_frequency = 1800;
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
    doom-emacs = {
      enable = true;
      emacs = pkgs.unstable.emacs29-pgtk;
      provideEmacs = true;
      experimentalFetchTree = true;
      doomDir = inputs.nixfigs-doom-emacs;
      doomLocalDir = "${homeDirectory}/.local/state/doom";
    };
    taskwarrior = {
      enable = true;
      config = {
        report = {
          minimal.filter = "status:pending";
          active.columns = [
            "id"
            "start"
            "entry.age"
            "priority"
            "project"
            "due"
            "description"
          ];
          active.labels = [
            "ID"
            "Started"
            "Age"
            "Priority"
            "Project"
            "Due"
            "Description"
          ];
        };
      };
    };
  };
  news.display = "silent";

  systemd.user = let
    taskwCommonConfig = {
      ConditionPathExists = "${config.xdg.configHome}/task/taskrc";
      ConditionPathIsDirectory = "${config.xdg.dataHome}/task";
    };
  in {
    timers = {
      task-sync = {
        Unit =
          taskwCommonConfig
          // {
            Description = "Taskwarrior auto sync timer";
          };
        Timer.OnCalendar = "*:0/30";
        Install.WantedBy = ["timers.target"];
      };
    };
    sessionVariables = {
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      MOZ_ENABLE_WAYLAND = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
    tmpfiles.rules = ["L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0"];
    services = {
      task-sync = {
        Unit =
          taskwCommonConfig
          // {
            Description = "Taskwarrior auto sync service";
          };
        Service = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.taskwarrior}/bin/task";
          ExecStart = "${pkgs.taskwarrior}/bin/task sync";
          ExecStartPost = "${pkgs.taskwarrior}/bin/task sync";
        };
      };
    };
  };

  xdg = {
    enable = true;
    configFile = {
      "emacs.src/doom-emacs" = {
        source = inputs.doom-emacs-src;
        recursive = true;
      };
      "emacs.src/spacemacs" = {
        source = inputs.spacemacs-src;
        recursive = true;
      };
    };
    portal = {
      config = {
        sway = {
          default = [
            "wlr"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
          "org.freedesktop.impl.portal.Screencast" = ["wlr"];
        };
      };
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      xdgOpenUsePortal = true;
    };
  };
}
