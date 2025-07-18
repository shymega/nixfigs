# Roles System Documentation

The Nixfigs configuration uses a role-based system to organize and categorize different types of systems and their configurations. This document explains how roles work and how to use them effectively.

## Overview

Roles are predefined categories that describe the purpose and characteristics of a system. They help organize configurations, enable conditional module loading, and provide a consistent way to manage different types of hosts.

## Available Roles

### System Type Roles

- **`workstation`**: Desktop/laptop systems with full GUI, development tools, and multimedia capabilities
- **`minimal`**: Minimal server configurations with only essential packages
- **`container`**: Container-based deployments with reduced system services
- **`embedded`**: Embedded systems like Raspberry Pi with resource constraints

### Platform Roles

- **`darwin`**: macOS systems
- **`darwin-arm64`**: Apple Silicon macOS systems
- **`darwin-x86`**: Intel macOS systems
- **`mobile-nixos`**: Mobile devices running NixOS
- **`nix-on-droid`**: Android devices with Nix

### Hardware Roles

- **`raspberrypi-arm64`**: Raspberry Pi 4 and newer (64-bit)
- **`raspberrypi-zero`**: Raspberry Pi Zero and similar (32-bit)
- **`gpd-duo`**: GPD Duo handheld device
- **`gpd-wm2`**: GPD Win Max 2 handheld device
- **`steam-deck`**: Valve Steam Deck
- **`jovian`**: Steam Deck with Jovian NixOS

### Environment Roles

- **`proxmox-lxc`**: Proxmox LXC containers
- **`proxmox-vm`**: Proxmox virtual machines
- **`wsl`**: Windows Subsystem for Linux
- **`github-runner`**: GitHub Actions self-hosted runners
- **`gitlab-runner`**: GitLab CI self-hosted runners

### Usage Roles

- **`personal`**: Personal use systems
- **`work`**: Work-related configurations
- **`gaming`**: Gaming-focused configurations with optimizations
- **`rnet`**: Rodriguez network infrastructure
- **`shynet`**: Shymega network infrastructure

## Role Utilities

The roles system provides several utility functions for working with roles:

### `checkRole(role)`

Validates if a role exists in the predefined roles list.

```nix
utils.checkRole "workstation"  # returns: true
utils.checkRole "nonexistent"  # returns: false
```

### `checkRoleIn(targetRole, hostRoles)`

Checks if a specific role is enabled for a host.

```nix
utils.checkRoleIn "gaming" ["workstation" "gaming" "personal"]  # returns: true
utils.checkRoleIn "server" ["workstation" "gaming" "personal"]  # returns: false
```

### `checkRoles(targetRoles, hostRoles)`

Checks if any of the target roles are present in the host roles.

```nix
utils.checkRoles ["gaming" "workstation"] ["personal" "gaming"]  # returns: true
utils.checkRoles ["server" "minimal"] ["personal" "gaming"]     # returns: false
```

### `checkAllRoles(targetRoles, hostRoles)`

Checks if all target roles are present in the host roles.

```nix
utils.checkAllRoles ["gaming" "personal"] ["workstation" "gaming" "personal"]  # returns: true
utils.checkAllRoles ["gaming" "server"] ["workstation" "gaming" "personal"]    # returns: false
```

## Using Roles in Configurations

### Host Configuration

Define roles when creating a host configuration:

```nix
# hosts/declarations/conf.d/EXAMPLE-HOST.nix
{
  mkHost,
  # ... other parameters
}:
mkHost {
  hostname = "EXAMPLE-HOST";
  hostRoles = ["workstation" "gaming" "personal"];
  # ... other configuration
}
```

### Conditional Module Loading

Use roles to conditionally load modules:

```nix
# src/modules/nixos/common/default.nix
{
  lib,
  hostname,
  ...
}: let
  inherit (lib) optionals;
  inherit (inputs.nixfigs.utils) checkRoleIn;
  hostRoles = config.nixfigs.meta.rolesEnabled or [];
in {
  imports = [
    ./base.nix
  ] ++ optionals (checkRoleIn "gaming" hostRoles) [
    ./gaming.nix
  ] ++ optionals (checkRoleIn "workstation" hostRoles) [
    ./desktop.nix
  ];
}
```

### Role-Based Package Selection

```nix
# src/modules/nixos/common/packages.nix
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (inputs.nixfigs.utils) checkRoleIn;
  hostRoles = config.nixfigs.meta.rolesEnabled or [];
in {
  environment.systemPackages = with pkgs; [
    # Base packages for all systems
    git
    curl
  ] ++ lib.optionals (checkRoleIn "workstation" hostRoles) [
    # Workstation-specific packages
    firefox
    libreoffice
  ] ++ lib.optionals (checkRoleIn "gaming" hostRoles) [
    # Gaming-specific packages
    steam
    lutris
  ] ++ lib.optionals (checkRoleIn "minimal" hostRoles) [
    # Minimal system packages
    htop
    tmux
  ];
}
```

### Service Configuration

```nix
# Enable services based on roles
{
  config,
  lib,
  ...
}: let
  inherit (inputs.nixfigs.utils) checkRoleIn;
  hostRoles = config.nixfigs.meta.rolesEnabled or [];
in {
  services.xserver.enable = checkRoleIn "workstation" hostRoles;
  services.openssh.enable = !checkRoleIn "minimal" hostRoles;
  
  # Gaming-specific services
  programs.steam.enable = checkRoleIn "gaming" hostRoles;
  hardware.steam-hardware.enable = checkRoleIn "gaming" hostRoles;
}
```

## Best Practices

### Role Assignment

1. **Be Specific**: Use the most specific roles that describe your system
2. **Multiple Roles**: Systems can have multiple roles (e.g., `["workstation", "gaming", "personal"]`)
3. **Inheritance**: Some roles imply others (e.g., `workstation` typically includes basic desktop functionality)

### Module Organization

1. **Conditional Imports**: Use role checks in module imports rather than complex conditional logic
2. **Role-Specific Modules**: Create modules that are only loaded for specific roles
3. **Default Configurations**: Provide sensible defaults that work across roles

### Testing

1. **Multi-Role Testing**: Test configurations with different role combinations
2. **Role Validation**: Ensure role utility functions work correctly
3. **Dependency Checking**: Verify that role dependencies are properly handled

## Examples

### Gaming Workstation

```nix
hostRoles = ["workstation" "gaming" "personal"];
```

This configuration would:
- Load desktop environment (workstation)
- Enable gaming optimizations (gaming)
- Use personal user configurations (personal)

### Minimal Server

```nix
hostRoles = ["minimal" "rnet"];
```

This configuration would:
- Use minimal package set (minimal)
- Enable network infrastructure modules (rnet)
- Disable desktop environment and GUI packages

### Development Machine

```nix
hostRoles = ["workstation" "personal"];
```

This configuration would:
- Enable full desktop environment (workstation)
- Load development tools and personal configurations (personal)
- Skip gaming optimizations

## Extending the Roles System

### Adding New Roles

1. Add the role to the `roles` list in `nix-support/roles.nix`
2. Document the role in this file
3. Create or update modules to use the new role
4. Test the new role with appropriate configurations

### Creating Role-Specific Modules

```nix
# src/modules/nixos/roles/my-new-role.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs.nixfigs.utils) checkRoleIn;
  hostRoles = config.nixfigs.meta.rolesEnabled or [];
in {
  config = lib.mkIf (checkRoleIn "my-new-role" hostRoles) {
    # Role-specific configuration
  };
}
```

## Migration Notes

When migrating from older configurations:

1. Review existing host configurations and assign appropriate roles
2. Update conditional logic to use role utilities
3. Test all configurations to ensure proper role handling
4. Document any custom role usage patterns