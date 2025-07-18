# Nixfigs - Dom's NixOS Configuration

This repository contains Dom Rodriguez's personal NixOS configuration flake, managing multiple systems across different architectures and use cases.

## Overview

This flake provides a comprehensive NixOS configuration system with support for:
- Multiple host configurations (workstations, servers, embedded devices)
- Role-based system organization
- Secure secrets management with sops-nix
- Home Manager integration
- Cross-platform support (Linux, macOS)
- Automated deployment with deploy-rs

## Quick Start

### Prerequisites

- Nix with flakes enabled
- Git
- SOPS (for secrets management)
- Age or GPG keys for encryption

### Building a Configuration

```bash
# Build a specific host configuration
nix build .#nixosConfigurations.DEUSEX-LINUX.config.system.build.toplevel

# Build all packages
nix build .#packages.x86_64-linux.totp

# Enter development shell
nix develop
```

### Deploying to Remote Hosts

```bash
# Deploy to a specific host
nix run .#deploy.nodes.DEUSEX-LINUX

# Deploy to all hosts
nix run .#deploy
```

## Project Structure

```
├── flake.nix                   # Main flake configuration
├── hosts/                      # Host-specific configurations
│   ├── declarations/           # Host declarations
│   ├── nixos/                  # NixOS host definitions
│   ├── darwin/                 # macOS host definitions
│   └── homes/                  # Home Manager configurations
├── src/
│   ├── modules/                # Reusable NixOS modules
│   │   ├── core/               # Core system modules
│   │   ├── nixos/              # NixOS-specific modules
│   │   ├── darwin/             # macOS-specific modules
│   │   └── home/               # Home Manager modules
│   └── systems/                # System-specific configurations
├── nix-support/                # Build and development support
│   ├── roles.nix               # Role definitions and utilities
│   ├── systems.nix             # System definitions
│   ├── deploy.nix              # Deployment configuration
│   ├── devshell.nix            # Development shell
│   ├── formatter.nix           # Code formatting
│   ├── hydra.nix               # Hydra CI jobs
│   ├── github-actions.nix      # GitHub Actions matrix
│   └── builds.nix              # Build artifacts
├── overlays/                   # Nixpkgs overlays
├── packages/                   # Custom packages
├── secrets/                    # Encrypted secrets (sops-nix)
└── lib/                        # Utility functions
```

## Host Roles

The configuration uses a role-based system to organize different types of hosts:

### Available Roles

- **workstation**: Desktop/laptop systems with full GUI
- **personal**: Personal use systems
- **gaming**: Gaming-focused configurations
- **minimal**: Minimal server configurations
- **container**: Container-based deployments
- **embedded**: Embedded systems (Raspberry Pi, etc.)
- **darwin**: macOS systems
- **work**: Work-related configurations
- **steam-deck**: Steam Deck specific configurations
- **gpd-duo**: GPD Duo handheld specific configurations

### Role Utilities

```nix
# Check if a role is valid
utils.checkRole "workstation"  # true/false

# Check if a role is enabled for a host
utils.checkRoleIn "gaming" ["workstation" "gaming" "personal"]  # true

# Check if any target roles are in host roles
utils.checkRoles ["gaming" "workstation"] ["personal" "gaming"]  # true
```

## Secrets Management

This configuration uses sops-nix for secure secrets management with multiple encryption methods:

### Encryption Methods

1. **Age encryption** using SSH host keys
2. **GPG encryption** for additional security
3. **Yubikey PIV slots** for hardware-backed encryption

### Managing Secrets

```bash
# Edit secrets for a specific host
sops secrets/hosts/DEUSEX-LINUX/passwords.yaml

# Create new secrets file
sops --config .sops.yaml secrets/global/new-secret.yaml
```

### Secrets Structure

```
secrets/
├── global/          # Secrets available to all hosts
├── hosts/           # Host-specific secrets
│   └── HOSTNAME/
└── users/           # User-specific secrets
```

## Development

### Development Shell

The repository includes a development shell with all necessary tools:

```bash
# Enter development shell
nix develop

# Available tools:
# - deploy-rs: Remote deployment
# - sops: Secrets management
# - pre-commit: Code quality checks
# - statix: Nix linting
# - alejandra: Nix formatting
```

### Code Quality

```bash
# Format all code
nix fmt

# Run pre-commit checks
pre-commit run --all-files

# Check Nix code quality
statix check .
```

### Testing

```bash
# Build all configurations
nix flake check

# Test specific configuration
nix build .#nixosConfigurations.DEUSEX-LINUX.config.system.build.toplevel
```

## Deployment

### Deploy-rs Configuration

The flake includes automated deployment using deploy-rs:

```bash
# Deploy to specific host
nix run .#deploy.nodes.DEUSEX-LINUX

# Deploy to all configured hosts
nix run .#deploy
```

### GitHub Actions

Automated builds and checks run on:
- Pull requests
- Pushes to main branch
- Scheduled builds

Matrix includes all supported systems and configurations.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the existing patterns
4. Run code quality checks
5. Test your changes
6. Submit a pull request

### Adding New Hosts

1. Create host declaration in `hosts/declarations/conf.d/`
2. Add host to `hosts/declarations/enabled.d/`
3. Create system configuration in `src/systems/`
4. Define appropriate roles
5. Add secrets if needed

### Adding New Modules

1. Create module in appropriate `src/modules/` subdirectory
2. Follow existing module patterns
3. Document module options
4. Add to appropriate import lists

## License

This configuration is licensed under GPL-3.0-only.

## Support

For issues and questions, please open an issue in the repository.