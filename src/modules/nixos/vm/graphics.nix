# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, lib, pkgs, ... }:
let
  inherit (lib) checkRoles;
  isVM = checkRoles ["virtual-machine"] config;
in {
  config = lib.mkIf isVM {
    # Hyprland configuration for VM
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Auto-login configuration
    services.displayManager = {
      autoLogin = {
        enable = true;
        user = "domrodriguez";
      };
    };

    # Use greetd with auto-login to Hyprland
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = "domrodriguez";
        };
      };
    };

    # Disable other display managers
    services.xserver = {
      enable = false;
      displayManager.gdm.enable = lib.mkForce false;
    };

    # VM user configuration
    users.users.domrodriguez = {
      isNormalUser = true;
      description = "Dom Rodriguez";
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
      hashedPassword = "$6$placeholder"; # Replace with actual hashed password
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlaceholderVMUserSSHKey" # Replace with actual key
      ];
    };

    # Hyprland VM configuration
    environment.etc."hypr/hyprland.conf".text = ''
      # Hyprland VM Configuration
      
      # Monitor setup (auto-detect VM display)
      monitor=,preferred,auto,1
      
      # VM-optimized settings
      misc {
        disable_hyprland_logo = true
        disable_splash_rendering = true
        force_default_wallpaper = 0
        vfr = true
      }
      
      # Input configuration
      input {
        kb_layout = us
        follow_mouse = 1
        touchpad {
          natural_scroll = false
        }
        sensitivity = 0
      }
      
      # Workspace rules for VM
      workspace = 1, monitor:, default:true
      
      # Window rules for VM applications
      windowrulev2 = opacity 0.9 0.9,class:^(firefox)$
      windowrulev2 = opacity 0.9 0.9,class:^(kitty)$
      
      # Key bindings
      $mainMod = SUPER
      
      bind = $mainMod, Return, exec, kitty
      bind = $mainMod, Q, killactive,
      bind = $mainMod, M, exit,
      bind = $mainMod, E, exec, thunar
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, R, exec, wofi --show drun
      bind = $mainMod, P, pseudo,
      bind = $mainMod, J, togglesplit,
      
      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      
      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      
      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      
      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      
      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
      
      # Auto-start applications
      exec-once = waybar
      exec-once = rustdesk --service
    '';

    # Essential GUI applications for VM
    environment.systemPackages = with pkgs; [
      # Terminal
      kitty
      
      # Browser
      firefox
      
      # File manager
      thunar
      
      # Application launcher
      wofi
      
      # Status bar
      waybar
      
      # Basic utilities
      grim # Screenshots
      slurp # Screen selection
      wl-clipboard # Clipboard
      
      # Rustdesk for remote access
      rustdesk
    ];

    # Audio configuration for VM
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Fonts for VM
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];
  };
}