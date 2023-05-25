{ config, inputs, pkgs, lib, ... }: {
  environment.darwinConfig = inputs.self
    + "/darwin-hosts/mac-vm/configuration.nix";

  networking = {
    computerName = "DZR-MACOS-DESKTOP-01"; # Host name
    hostName = "DZR-MACOS-DESKTOP-01";
  };

  fonts = {
    # Fonts
    fontDir.enable = true;
    fonts = with pkgs; [
      source-code-pro
      font-awesome
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
  };

  environment = {
    shells = with pkgs; [ zsh ]; # Default shell
    variables = {
      # System variables
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      # Installed Nix packages
      git
      ranger
      atuin
      neovim
    ];
  };

  programs = {
    # Shell needs to be enabled
    zsh.enable = true;
  };

  services = {
    nix-daemon.enable = true; # Auto upgrade daemon
  };

  homebrew = {
    # Declare Homebrew using Nix-Darwin
    enable = true;
    onActivation = {
      autoUpdate = false; # Auto update packages
      upgrade = false;
      cleanup = "zap"; # Uninstall not listed packages and casks
    };
    brews = [ "wireguard-tools" ];
    casks = [ "parsec" ];
  };

  nix = {
    package = pkgs.nix;
    gc = {
      # Garbage collection
      automatic = true;
      options = "--delete-older-than 14d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    optimise.automatic = true;

    settings.sandbox = "relaxed";
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        # Global macOS system settings
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      dock = {
        # Dock settings
        autohide = true;
        orientation = "bottom";
        showhidden = true;
        tilesize = 40;
      };
      finder = {
        # Finder settings
        QuitMenuItem =
          false; # I believe this probably will need to be true if using spacebar
      };
      trackpad = {
        # Trackpad settings
        Clicking = true;
        TrackpadRightClick = true;
      };
    };
    activationScripts.postActivation.text =
      "sudo chsh -s ${pkgs.zsh}/bin/zsh"; # Since it's not possible to declare default shell, run this command after build
    stateVersion = 4;
  };

  services.nix-daemon.enable = true;

  system.stateVersion = 4;
}
