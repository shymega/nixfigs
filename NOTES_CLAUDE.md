# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

# Claude Implementation Notes

This document chronicles all the work done by Claude to implement secure work laptop configuration, VM setup, and git-crypt encryption for this NixOS flake.

## Overview

Claude implemented a comprehensive secure configuration system with the following major features:

1. **Work Laptop Configuration (`ct-lt-2671`)** - Secure work environment with role-based isolation
2. **VM Configuration (`ct-vm-domrodriguez`)** - Libvirt VM with Hyprland and Rustdesk remote access
3. **Git-Crypt Integration** - Repository-level encryption for work-specific files
4. **Enhanced SOPS Architecture** - Auto-populated secrets management
5. **Justfile Enhancements** - Comprehensive build and management commands

---

## 1. Work Laptop Configuration (ct-lt-2671)

### Architecture

Created a secure work laptop configuration with strict role-based isolation and corporate compliance features.

#### Key Components

**Host Declaration (`hosts/declarations/conf.d/ct-lt-2671.nix`)**
- Work-only roles: `["workstation", "work"]`
- Secure boot with Lanzaboote
- TPM integration
- Disabled remote build and deployment for security

**Work-Specific Modules (`src/modules/nixos/work/`)**
- `default.nix` - Role enforcement with mutual exclusion
- `networking.nix` - Corporate networks, blocked personal services
- `applications.nix` - Work-approved software only
- `compliance.nix` - Security hardening, audit logging
- `monitoring.nix` - Corporate monitoring and health checks

**System Configuration (`src/systems/ct-lt-2671@x86_64-linux/`)**
- LUKS disk encryption
- Kernel hardening parameters
- Work user configuration
- Security-focused boot configuration

#### Security Features

**Role-Based Isolation**
```nix
# Mutual exclusion enforcement
assertions = [{
  assertion = !(isWork && isPersonal);
  message = "Cannot have both work and personal roles";
}];
```

**Network Security**
- Blocks personal services (Syncthing, Dropbox)
- Corporate WiFi configuration
- Firewall rules for work environment

**Application Control**
- Work-approved applications only
- Corporate browser policies
- Restricted package installation

**Compliance**
- Audit logging enabled
- Firmware updates enforced
- Security hardening parameters
- Build-time validation assertions

### SOPS Integration

**Separate Secret Architecture**
```
secrets/
├── work/hosts/ct-lt-2671/
│   ├── passwords.yaml
│   ├── wifi-credentials.yaml
│   └── ...
└── personal/hosts/*/
    └── passwords.yaml
```

**Role-Based Secret Loading**
- Work systems only access work secrets
- Personal systems only access personal secrets
- Auto-populated secret configurations from YAML files

---

## 2. VM Configuration (ct-vm-domrodriguez)

### Architecture

Created a libvirt VM configuration with Hyprland desktop and Rustdesk remote access, designed to run on DEUSEX-LINUX.

#### Key Components

**Host Declaration (`hosts/declarations/conf.d/ct-vm-domrodriguez.nix`)**
- VM roles: `["virtual-machine", "personal", "workstation", "libvirt"]`
- Optimized for virtualization

**VM-Specific Modules (`src/modules/nixos/vm/`)**
- `default.nix` - VM role detection and module imports
- `libvirt.nix` - QEMU/KVM optimizations
- `graphics.nix` - Hyprland with auto-login
- `networking.nix` - VM network configuration
- `rustdesk.nix` - Remote desktop service

**System Configuration (`src/systems/ct-vm-domrodriguez@x86_64-linux/`)**
- ZFS-backed storage
- VM hardware optimization
- Auto-login user setup

#### Features

**Hyprland Desktop**
- Auto-login as `domrodriguez` user
- VM-optimized Hyprland configuration
- Essential GUI applications (Firefox, Kitty, Waybar)

**Rustdesk Remote Desktop**
- Service runs automatically
- Restricted to host network (192.168.122.0/24)
- Firewall rules block external access
- Health monitoring and logging

**ZFS Storage**
- Separate datasets: root, home, nix
- Host-managed ZFS pool
- VM-level snapshots enabled

**Network Security**
- Host-only access via libvirt network
- Firewall restrictions
- Network optimization for VMs

### VM Storage Layout
```
vmpool/ct-vm-domrodriguez/
├── root    # System files
├── home    # User data
└── nix     # Nix store
```

---

## 3. Git-Crypt Implementation

### Architecture

Implemented repository-level encryption for work-specific configurations using git-crypt with GPG and symmetric key support.

#### Configuration Files

**`.gitattributes`**
Defines encryption patterns:
```
src/modules/nixos/work/** filter=git-crypt diff=git-crypt
src/systems/ct-lt-2671@x86_64-linux/** filter=git-crypt diff=git-crypt
secrets/work/** filter=git-crypt diff=git-crypt
hosts/declarations/conf.d/ct-lt-2671.nix filter=git-crypt diff=git-crypt
```

**`.git-crypt-keys`**
GPG key management reference with instructions for adding users and managing keys.

**`.git-crypt-pre-commit`**
Pre-commit hook that ensures git-crypt is unlocked when committing work files.

#### Justfile Integration

Added comprehensive git-crypt management commands:

**Basic Operations**
- `just git-crypt-status` - Check encryption status
- `just git-crypt-unlock` - Decrypt work files
- `just git-crypt-lock` - Encrypt work files

**Key Management**
- `just git-crypt-init` - Initialize git-crypt
- `just git-crypt-add-user FINGERPRINT` - Add GPG user
- `just git-crypt-export-key` - Export symmetric key

**Development Workflow**
- `just validate-work-build` - Build with encryption validation
- `just git-crypt-list-encrypted` - Show encrypted files

#### Security Model

**Double Encryption for Work Secrets**
1. **SOPS-NIX**: Application-level encryption with age/GPG
2. **Git-crypt**: Repository-level encryption with GPG/symmetric keys

**Access Control**
- GPG keys for individual access
- Symmetric key for automation/backup
- Role-based file encryption

**Workflow Integration**
- Pre-commit validation
- Build-time encryption checks
- Automatic file encryption on commit

### Key Management

**Symmetric Key Handling**
- Automatically created during `git-crypt init`
- Stored in `.git/git-crypt/keys/default`
- Exported via `just git-crypt-export-key`
- Used for CI/CD and backup scenarios

**GPG Key Access**
- Primary access method for users
- Added via `just git-crypt-add-user FINGERPRINT`
- Provides secure access to symmetric key
- Supports team collaboration

---

## 4. Enhanced SOPS Architecture

### Auto-Population System

Refactored SOPS configuration to automatically generate secret configurations from YAML files, eliminating dual maintenance.

#### Implementation

**Helper Function**
```nix
mkSecret = name: file: extraAttrs: {
  ${name} = {
    sopsFile = file;
    path = "/run/secrets/${name}";
    mode = "0400";
    owner = "root";
    group = "root";
  } // extraAttrs;
};
```

**Auto-Generated Secrets**
```nix
workSecrets = 
  (mkSecret "workuser-password" ../../../secrets/work/hosts/${hostname}/passwords.yaml { neededForUsers = true; }) //
  (mkSecret "luks-password" ../../../secrets/work/hosts/${hostname}/passwords.yaml {}) //
  # ... more secrets automatically configured
```

#### Benefits

- **Single Source of Truth**: Secret names only defined in YAML files
- **Consistent Configuration**: All secrets get proper paths and permissions
- **Role-Based Loading**: Work secrets only on work systems
- **Easy Maintenance**: Add secrets to YAML, Nix auto-updates

---

## 5. Justfile Enhancements

### Comprehensive Build System

Enhanced the Justfile with work-specific commands and git-crypt integration.

#### Work-Specific Commands

**Build Commands**
- `just build-work` - Build work laptop specifically
- `just switch-work` - Switch to work configuration
- `just test-work` - Test work configuration

**Host Management**
- `just hosts-work` - Show work hosts
- `just hosts-personal` - Show personal hosts

#### Secrets Management

**Role-Based Secret Commands**
- `just edit-work-secrets FILE` - Edit work secrets
- `just edit-personal-secrets HOST FILE` - Edit personal secrets
- `just rotate-work-secrets` - Rotate work keys only
- `just validate-secrets` - Validate all secret decryption

#### Git-Crypt Integration

**Complete git-crypt workflow integrated into build system**
- Automatic encryption status checking
- Build validation with unlock requirements
- Key management commands
- Development workflow support

---

## 6. Directory Structure

### Created Structure
```
nixfigs/
├── .gitattributes                    # Git-crypt encryption patterns
├── .git-crypt-keys                   # GPG key management reference
├── .git-crypt-pre-commit            # Pre-commit validation hook
├── docs/
│   └── GIT-CRYPT-SETUP.md          # Comprehensive git-crypt guide
├── hosts/declarations/conf.d/
│   ├── ct-lt-2671.nix               # Work laptop (encrypted)
│   └── ct-vm-domrodriguez.nix       # VM configuration
├── secrets/
│   ├── work/                        # Work secrets (double-encrypted)
│   │   ├── hosts/ct-lt-2671/
│   │   │   ├── passwords.yaml
│   │   │   └── wifi-credentials.yaml
│   │   └── shared/
│   │       └── corporate-ca.yaml
│   └── personal/                    # Personal secrets (SOPS only)
│       └── hosts/*/passwords.yaml
├── src/
│   ├── modules/nixos/
│   │   ├── work/                    # Work modules (encrypted)
│   │   │   ├── default.nix
│   │   │   ├── networking.nix
│   │   │   ├── applications.nix
│   │   │   ├── compliance.nix
│   │   │   └── monitoring.nix
│   │   └── vm/                      # VM modules
│   │       ├── default.nix
│   │       ├── libvirt.nix
│   │       ├── graphics.nix
│   │       ├── networking.nix
│   │       └── rustdesk.nix
│   └── systems/
│       ├── ct-lt-2671@x86_64-linux/ # Work system (encrypted)
│       │   ├── default.nix
│       │   └── hardware-configuration.nix
│       └── ct-vm-domrodriguez@x86_64-linux/
│           ├── default.nix
│           └── hardware-configuration.nix
└── Justfile                         # Enhanced with git-crypt commands
```

---

## 7. Security Architecture

### Defense in Depth

**Multiple Security Layers**
1. **Role-based access control** - Work/personal mutual exclusion
2. **SOPS-NIX encryption** - Application-level secrets encryption
3. **Git-crypt encryption** - Repository-level file encryption
4. **Network isolation** - Firewall rules and service blocking
5. **System hardening** - Kernel parameters and compliance

### Access Control Matrix

| Resource Type | Personal | Work | VM |
|--------------|----------|------|-----|
| Personal Modules | ✅ | ❌ | ✅ |
| Work Modules | ❌ | ✅ | ❌ |
| Personal Secrets | ✅ | ❌ | ❌ |
| Work Secrets | ❌ | ✅ | ❌ |
| VM Modules | ✅ | ❌ | ✅ |

### Encryption Layers

**Work Secrets: Double Encryption**
- Layer 1: SOPS-NIX (age/GPG) - Application-level
- Layer 2: Git-crypt (GPG/symmetric) - Repository-level

**Personal Secrets: Single Encryption**
- Layer 1: SOPS-NIX (age/GPG) - Application-level

**VM Secrets: Single Encryption**
- Layer 1: SOPS-NIX (age/GPG) - Application-level

---

## 8. Implementation Timeline

### Phase 1: Work Configuration
1. ✅ Created work-specific module structure
2. ✅ Implemented role-based security boundaries
3. ✅ Set up separate secrets architecture
4. ✅ Added work laptop system configuration
5. ✅ Enhanced SOPS with auto-population

### Phase 2: VM Configuration  
1. ✅ Created VM host declaration
2. ✅ Implemented VM-specific modules
3. ✅ Set up Hyprland with auto-login
4. ✅ Configured Rustdesk with network restrictions
5. ✅ Added ZFS-backed storage configuration

### Phase 3: Git-Crypt Integration
1. ✅ Set up .gitattributes encryption patterns
2. ✅ Added git-crypt management commands
3. ✅ Created comprehensive documentation
4. ✅ Implemented pre-commit validation
5. ✅ Integrated with build system

---

## 9. Usage Workflows

### Work Laptop Development

**Daily Workflow**
```bash
# 1. Unlock work configurations
just git-crypt-unlock

# 2. Edit work configurations
vim src/modules/nixos/work/applications.nix

# 3. Edit work secrets
just edit-work-secrets passwords

# 4. Build and test
just validate-work-build

# 5. Commit (files auto-encrypt)
git add .
git commit -m "Update work configuration"

# 6. Deploy to work laptop
just switch-work
```

### VM Management

**VM Setup on Host (DEUSEX-LINUX)**
```bash
# 1. Create ZFS datasets
zfs create vmpool/ct-vm-domrodriguez
zfs create vmpool/ct-vm-domrodriguez/root
zfs create vmpool/ct-vm-domrodriguez/home
zfs create vmpool/ct-vm-domrodriguez/nix

# 2. Build VM configuration
just build ct-vm-domrodriguez

# 3. Create libvirt VM
virt-install --name ct-vm-domrodriguez ...

# 4. Access via Rustdesk
# Connect to VM IP:21116 from host only
```

### Team Collaboration

**Adding New Team Member**
```bash
# 1. Add team member's GPG key
just git-crypt-add-user TEAMMATE_GPG_FINGERPRINT

# 2. Commit the key addition
git add .git-crypt/keys/
git commit -m "Add teammate GPG key for work access"

# 3. Team member can now access
git clone repo
git-crypt unlock  # Uses their GPG key automatically
```

---

## 10. Maintenance and Operations

### Regular Tasks

**Secret Rotation**
```bash
# Rotate work secrets only
just rotate-work-secrets

# Rotate personal secrets only  
just rotate-personal-secrets

# Validate all secrets
just validate-secrets
```

**Git-Crypt Maintenance**
```bash
# Check encryption status
just git-crypt-status

# List encrypted files
just git-crypt-list-encrypted

# Export backup key
just git-crypt-export-key
```

**System Updates**
```bash
# Update work system
just update && just build-work && just switch-work

# Update VM
just update && just build ct-vm-domrodriguez
```

### Troubleshooting

**Common Issues and Solutions**

1. **Git-crypt locked during build**
   ```bash
   just git-crypt-unlock
   just validate-work-build
   ```

2. **SOPS secrets not decrypting**
   ```bash
   just validate-secrets
   # Check age/GPG key configuration
   ```

3. **VM network access issues**
   ```bash
   # Check libvirt network
   virsh net-list
   # Verify firewall rules on VM
   ```

---

## 11. Future Enhancements

### Planned Improvements

**Security Enhancements**
- Hardware security module integration
- Yubikey support for git-crypt
- Additional audit logging

**VM Improvements**
- GPU passthrough for better graphics
- USB device passthrough
- Snapshot management automation

**Build System**
- CI/CD integration with git-crypt
- Automated testing for work configurations
- Cross-platform build support

### Extension Points

**New Work Systems**
- Add new work laptop: copy ct-lt-2671 pattern
- Corporate server configs: extend work modules
- Mobile device management: add mobile roles

**Additional VMs**
- Development environments
- Testing sandboxes
- Isolated workspaces

---

## 12. Documentation References

### Created Documentation
- `docs/GIT-CRYPT-SETUP.md` - Complete git-crypt guide
- `.git-crypt-keys` - Key management reference
- This file (`NOTES_CLAUDE.md`) - Implementation chronicle

### Existing Documentation Enhanced
- `Justfile` - Added comprehensive command reference
- `README.md` - Should be updated with new features
- Role definitions - Work role now fully implemented

### Configuration Examples
- Work laptop: Complete corporate compliance setup
- VM: Full virtualization with remote access
- Git-crypt: Repository-level encryption patterns

---

## 13. Testing and Validation

### Implemented Tests

**Build Validation**
- `just validate-work-build` - Ensures git-crypt unlocked
- Role assertion tests - Prevents work/personal mixing
- SOPS validation - Checks secret decryption

**Security Validation**
- Git-crypt pre-commit hook
- Network isolation testing
- Secret access control verification

### Manual Testing Procedures

**Work Configuration**
1. Build work system: `just build-work`
2. Verify role isolation: Check assertions
3. Test secret access: `just validate-secrets`
4. Validate network restrictions

**VM Configuration**
1. Build VM: `just build ct-vm-domrodriguez`
2. Test auto-login: Verify Hyprland starts
3. Test Rustdesk: Connect from host only
4. Verify ZFS integration

**Git-Crypt**
1. Initialize: `just git-crypt-init`
2. Test encryption: `just git-crypt-lock`
3. Test decryption: `just git-crypt-unlock`
4. Verify file patterns work correctly

---

## 14. Commit History

### Major Commits Made

1. **Work Configuration** (`c960e44b`)
   - Complete secure work laptop setup
   - Role-based security implementation
   - Separate secrets architecture

2. **SOPS Auto-Population** (`6c50434e`)
   - Refactored secrets management
   - Eliminated dual maintenance
   - Auto-generated configurations

3. **VM Configuration** (`f5bbed71`)
   - Libvirt VM with Hyprland
   - Rustdesk remote desktop
   - ZFS-backed storage

4. **Git-Crypt Implementation** (`7d435601`)
   - Repository-level encryption
   - Comprehensive management tools
   - Double encryption for work secrets

### Branch Structure
- `refactor/mk-v` - Main development branch
- `refactor/mk-v--git-crypt` - Git-crypt feature branch

---

This document serves as a complete reference for all work done by Claude on this NixOS flake, providing both implementation details and operational guidance for maintaining and extending the system.