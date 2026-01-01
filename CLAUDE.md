# CLAUDE.md - AI Assistant Guidelines for Nixfigs Repository

This document provides guidance for AI assistants (Claude, Gemini, etc.) working with this NixOS configuration repository.

## Repository Overview

This is a personal NixOS configuration flake managing multiple systems across different architectures using a role-based modular architecture.

**Key characteristics:**
- Nix flakes-based configuration
- SPDX license headers on all files
- Formatted with `alejandra`
- Role-based system organization
- Secrets managed with sops-nix
- Multi-architecture support (x86_64, aarch64, armv6l, riscv64)

## Commit Message Conventions

**ALWAYS** follow the Conventional Commits specification:

### Format
```
<type>: <description>

[optional body]
[optional footer]
```

### Types
- `feat:` - New features or functionality
- `fix:` - Bug fixes
- `chore:` - Maintenance tasks (dependency updates, cleanup)
- `refactor:` - Code restructuring without behavior changes
- `docs:` - Documentation changes
- `revert:` - Reverting previous commits

### Rules
1. Use lowercase for type and description
2. Keep description concise (under 72 characters)
3. Use present tense ("add" not "added")
4. Use backticks for code/technical terms (e.g., `` `pkgs.system` ``)
5. Be specific and descriptive

### Examples
```
feat: Add Hyprland plugins, and lock Hyprland
fix: Fix `pkgs.system` usages
chore: Uprev various Flake inputs
refactor: Format with `alejandra`
docs: add comprehensive implementation documentation
```

### Common Patterns
- **Dependency updates**: `chore: Uprev various Flake inputs` or `chore: Update Flake inputs`
- **Formatting**: `chore: Run \`nix fmt\`` or `refactor: Format with \`alejandra\``
- **Version bumps**: `feat: Uprev to Nixpkgs 25.11`
- **Cleanup**: `chore: Remove unused \`nix\` directory`
- **Tidying**: `chore: Tidy up unclean diffs`

## Code Style and Formatting

### SPDX Headers

**EVERY** Nix file MUST start with SPDX headers:

```nix
# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
```

### Formatting

1. **Always run `nix fmt` before committing**
2. Use `alejandra` formatting style (configured in `nix-support/formatter.nix`)
3. The formatter runs automatically via pre-commit hooks

### Nix Code Patterns

#### Standard Module Structure
```nix
# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
{
  lib,
  pkgs,
  config,
  ...
}: let
  # Local bindings and helper functions
  isPersonal = hostname == "NEO-LINUX" || hostname == "MORPHEUS-LINUX";
in {
  # Module implementation
  imports = [
    ./submodule.nix
  ];

  # Configuration options
  services.example.enable = true;
}
```

#### Key Patterns

1. **Use `let-in` blocks** for local bindings
2. **Conditional imports** based on host type/role:
   ```nix
   imports = [
     ./always-imported.nix
   ] ++ (
     if isPersonal
     then [./personal.nix]
     else []
   );
   ```

3. **Inherit liberally** to reduce verbosity:
   ```nix
   let
     inherit (lib) mkIf mkDefault;
     inherit (pkgs) callPackage;
   in
   ```

4. **Use semantic naming**:
   - `isPersonal`, `isWorkstation`, `isMinimal` for boolean checks
   - `checkRole`, `checkRoles` for role validation
   - `genPkgs`, `forEachSystem` for generators

5. **Prefer explicit over implicit**:
   ```nix
   # Good
   pkgs.lib.strings.hasSuffix

   # Less preferred (but acceptable with inherit)
   inherit (pkgs.lib.strings) hasSuffix;
   hasSuffix "-LINUX" hostname
   ```

### Comments

- Use comments sparingly - code should be self-documenting
- Add comments for:
  - Non-obvious business logic
  - Hardware-specific workarounds
  - Security-sensitive configurations
  - Complex role-based conditionals

## File Organization

### Directory Structure

```
├── flake.nix                   # Main flake - minimal, delegates to nix-support/
├── hosts/
│   ├── declarations/conf.d/    # Host declaration files
│   ├── nixos/default.nix       # NixOS configurations builder
│   ├── darwin/default.nix      # macOS configurations builder
│   └── homes/default.nix       # Home Manager configurations builder
├── src/
│   ├── modules/
│   │   ├── core/               # Cross-platform core modules
│   │   ├── nixos/              # NixOS-specific modules
│   │   │   ├── common/         # Common NixOS modules
│   │   │   ├── work/           # Work-related modules
│   │   │   ├── vm/             # Virtual machine modules
│   │   │   └── installer/      # Installer-specific modules
│   │   ├── darwin/             # macOS-specific modules
│   │   └── home/               # Home Manager modules
│   ├── systems/                # Per-host system configurations
│   │   └── HOSTNAME@ARCH/      # e.g., NEO-LINUX@x86_64-linux/
│   └── homes/                  # Home Manager user configurations
├── nix-support/                # Build infrastructure
│   ├── roles.nix               # Role definitions
│   ├── systems.nix             # System helpers
│   ├── deploy.nix              # Deployment config
│   ├── formatter.nix           # Formatting config
│   ├── devshell.nix            # Development shell
│   ├── checks.nix              # Pre-commit checks
│   └── builds.nix              # Build artifacts
├── overlays/                   # Nixpkgs overlays
│   ├── stable/overlays.d/      # Overlays for stable nixpkgs
│   └── unstable/overlays.d/    # Overlays for unstable nixpkgs
├── packages/                   # Custom package definitions
├── lib/                        # Utility functions library
└── secrets/                    # SOPS-encrypted secrets
    ├── personal/
    └── work/
```

### Naming Conventions

1. **Hostnames**: UPPERCASE with suffix
   - Personal systems: `*-LINUX` (e.g., `NEO-LINUX`, `MORPHEUS-LINUX`)
   - Work systems: `ct-*` (e.g., `ct-lt-2671`, `ct-vm-domrodriguez`)
   - Embedded: Descriptive names (e.g., `DZR-BUSY-LIGHT`, `GRDN-BED-UNIT`)

2. **System paths**: `HOSTNAME@ARCHITECTURE/`
   - Example: `src/systems/NEO-LINUX@x86_64-linux/`
   - Example: `src/systems/ct-lt-2671@x86_64-linux/`

3. **Module files**: Lowercase with underscores or hyphens
   - `inst_packages.nix`, `common_env.nix`
   - `custom-systemd-units/`, `network-utils.nix`

4. **Overlays**: Package name in `overlays.d/`
   - `overlays/stable/overlays.d/davmail.nix`
   - `overlays/unstable/overlays.d/weechat.nix`

## Role-Based Architecture

### Available Roles

Defined in `nix-support/roles.nix`:

- `workstation` - Desktop/laptop with GUI
- `personal` - Personal use systems
- `gaming` - Gaming configurations
- `minimal` - Minimal server configs
- `container` - Container deployments
- `embedded` - Embedded systems (RPi, etc.)
- `darwin` - macOS systems
- `work` - Work-related configs
- `steam-deck` - Steam Deck specific
- `gpd-duo` - GPD Duo handheld specific

### Role Utilities

Available in `lib/default.nix` via `rolesModule.utils`:

```nix
# Check if single role is valid
utils.checkRole "workstation"  # → true/false

# Check if role is in list
utils.checkRoleIn "gaming" ["workstation" "gaming"]  # → true

# Check if any target roles match host roles
utils.checkRoles ["gaming" "workstation"] ["personal" "gaming"]  # → true
```

### Using Roles in Modules

```nix
{ lib, hostname, ... }: let
  inherit (lib) checkRoles;
  isPersonal = checkRoles ["personal"] hostRoles;
in {
  imports = [] ++ (if isPersonal then [./personal-config.nix] else []);
}
```

## Working with Secrets

### SOPS Configuration

1. Secrets are encrypted with `sops-nix`
2. Multiple encryption methods:
   - Age (SSH host keys)
   - GPG keys
   - Yubikey PIV slots

### Secret File Structure

```
secrets/
├── personal/
│   ├── .sops.yaml              # SOPS config for personal secrets
│   └── installer/
│       └── config.yaml
└── work/
    ├── hosts/
    │   └── HOSTNAME/
    │       ├── passwords.yaml
    │       └── wifi-credentials.yaml
    └── shared/
        └── corporate-ca.yaml
```

### Editing Secrets

```bash
# Edit host-specific secret
sops secrets/personal/hosts/NEO-LINUX/passwords.yaml

# Create new secret (follows .sops.yaml rules)
sops secrets/work/shared/new-secret.yaml
```

## Development Workflow

### Before Making Changes

1. **Understand the architecture**:
   - Review `flake.nix` for overall structure
   - Check `nix-support/roles.nix` for role definitions
   - Examine existing modules for patterns

2. **Check current state**:
   ```bash
   git status
   nix flake check  # Verify current config builds
   ```

### Making Changes

1. **Create feature branch** (if applicable):
   ```bash
   git checkout -b feat/description
   # or
   git checkout -b fix/description
   ```

2. **Make changes following patterns**:
   - Add SPDX headers to new files
   - Follow existing module structure
   - Use role-based conditionals where appropriate
   - Keep changes focused and minimal

3. **Format code**:
   ```bash
   nix fmt
   ```

4. **Test changes**:
   ```bash
   # Build specific configuration
   nix build .#nixosConfigurations.NEO-LINUX.config.system.build.toplevel

   # Run all checks
   nix flake check
   ```

5. **Commit with proper message**:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

### Adding New Components

#### New Host

1. Create declaration: `hosts/declarations/conf.d/HOSTNAME.nix`
2. Enable in: `hosts/declarations/enabled.d/`
3. Create system config: `src/systems/HOSTNAME@ARCH/default.nix`
4. Add hardware config: `src/systems/HOSTNAME@ARCH/hardware-configuration.nix`
5. Define roles in declaration
6. Add secrets if needed: `secrets/*/hosts/HOSTNAME/`

#### New Module

1. Choose correct location:
   - Core (cross-platform): `src/modules/core/`
   - NixOS-specific: `src/modules/nixos/common/`
   - Darwin-specific: `src/modules/darwin/`
   - Home Manager: `src/modules/home/`

2. Create module file with SPDX header
3. Add to appropriate `imports` list in parent `default.nix`
4. Use role-based conditionals if needed

#### New Overlay

1. Choose nixpkgs version:
   - Stable: `overlays/stable/overlays.d/`
   - Unstable: `overlays/unstable/overlays.d/`

2. Create overlay file: `overlays/{stable,unstable}/overlays.d/package-name.nix`

3. Structure:
   ```nix
   # SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
   #
   # SPDX-License-Identifier: GPL-3.0-only
   final: prev: {
     package-name = prev.package-name.overrideAttrs (oldAttrs: {
       # Modifications
     });
   }
   ```

#### New Package

1. Create package dir: `packages/package-name/`
2. Add `default.nix` with SPDX header
3. Reference in `flake.nix` packages output

## Common Tasks

### Updating Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Commit
git add flake.lock
git commit -m "chore: Update Flake inputs"
```

### Version Upgrades

When upgrading NixOS version (e.g., 24.11 → 25.11):

```bash
# Update inputs in flake.nix
# Update nixpkgs and home-manager refs to new version
nix flake update

git add flake.nix flake.lock
git commit -m "feat: Uprev to Nixpkgs 25.11"
```

### Formatting

```bash
# Format all Nix files
nix fmt

# Commit formatting changes
git add -A
git commit -m "chore: Run \`nix fmt\`"
# or
git commit -m "refactor: Format with \`alejandra\`"
```

### Testing Builds

```bash
# Build specific host
nix build .#nixosConfigurations.NEO-LINUX.config.system.build.toplevel

# Build all Home Manager configs
nix build .#homeConfigurations.dzrodriguez@x86_64-linux.activationPackage

# Run all checks (includes formatting, deploy-rs, pre-commit)
nix flake check

# Enter dev shell with all tools
nix develop
```

## Best Practices for AI Assistants

### DO

1. **Always add SPDX headers** to new Nix files
2. **Run `nix fmt`** after any code changes
3. **Use conventional commits** for all commits
4. **Follow existing patterns** - examine similar modules before creating new ones
5. **Test builds** before committing
6. **Use role-based conditionals** for feature toggles
7. **Keep changes minimal** - don't refactor unrelated code
8. **Preserve user customizations** - this is a personal config
9. **Use `lib` functions** instead of reinventing (`mkIf`, `mkDefault`, `genAttrs`, etc.)
10. **Reference existing code** when unsure of patterns

### DON'T

1. **Don't omit SPDX headers**
2. **Don't commit unformatted code**
3. **Don't use non-conventional commit messages**
4. **Don't add unnecessary complexity**
5. **Don't hardcode values** that should be parameterized
6. **Don't break existing host configurations**
7. **Don't add secrets in plain text** - use sops-nix
8. **Don't modify hardware-configuration.nix** unless explicitly asked
9. **Don't add features not requested** - keep scope focused
10. **Don't ignore build failures** - investigate and fix

### Code Review Checklist

Before presenting changes to user:

- [ ] SPDX headers on all new files
- [ ] Code formatted with `alejandra` (`nix fmt`)
- [ ] Conventional commit message(s)
- [ ] Follows existing patterns and structure
- [ ] Role-based conditionals used appropriately
- [ ] No hardcoded secrets or sensitive data
- [ ] Builds successfully (`nix build` or `nix flake check`)
- [ ] Changes are minimal and focused
- [ ] No unnecessary refactoring of unrelated code
- [ ] Documentation updated if needed (README.md, comments)

## Debugging and Troubleshooting

### Common Issues

1. **Build failures**: Check `nix-support/` for structural issues
2. **Role validation errors**: Verify roles defined in `nix-support/roles.nix`
3. **Import errors**: Check paths are correct relative to file location
4. **Formatting issues**: Run `nix fmt` and check `nix-support/formatter.nix`
5. **Secret decryption**: Verify `.sops.yaml` and encryption keys

### Useful Commands

```bash
# Show flake structure
nix flake show

# Show flake metadata
nix flake metadata

# Evaluate specific attribute
nix eval .#nixosConfigurations.NEO-LINUX.config.system.build.toplevel

# Build with verbose output
nix build --print-build-logs .#nixosConfigurations.NEO-LINUX.config.system.build.toplevel

# Check derivation
nix show-derivation .#nixosConfigurations.NEO-LINUX.config.system.build.toplevel
```

## Additional Context

### Repository Branches

- `main` - Primary stable branch
- `refactor/mk-v` - Current major refactor branch
- Feature branches: `feat/*`, `fix/*`, etc.

### CI/CD

- GitHub Actions for automated builds
- Hydra jobs configured in `nix-support/hydra.nix`
- Pre-commit hooks via `git-hooks.nix`

### External Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Remember**: This is a personal configuration repository. Respect the owner's preferences, patterns, and existing structure. When in doubt, ask before making significant architectural changes.
