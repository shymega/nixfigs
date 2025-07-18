# NixOS Installer ISO Configuration

This directory contains the configuration for building a generic NixOS installer ISO with the following features:

## Features

- **ZFS Support**: Full ZFS utilities and kernel support for advanced storage management
- **ZeroTier Networking**: Automatic connection to your ZeroTier network for remote access
- **SSH Access**: Pre-configured SSH access with your public keys
- **Multi-architecture**: Supports both x86_64 and aarch64 architectures
- **Minimal Dependencies**: Only essential packages for installation and troubleshooting

## Prerequisites

### 1. Configure Secrets

Before building the ISO, you need to configure your secrets:

```bash
# Edit the secrets file
cd secrets/personal/installer
cp config.yaml config.yaml.backup
sops config.yaml
```

Add your actual values:
- `zerotier-network-id`: Your ZeroTier network ID
- `installer-ssh-keys`: List of SSH public keys for access

### 2. Build the ISO

```bash
# For x86_64
nix build .#nixosConfigurations.installer-iso-x86_64.config.system.build.isoImage

# For aarch64
nix build .#nixosConfigurations.installer-iso-aarch64.config.system.build.isoImage
```

### 3. Create Bootable Media

```bash
# Find the ISO file
ls -la result/iso/

# Write to USB drive (replace /dev/sdX with your device)
sudo dd if=result/iso/nixos-installer-*.iso of=/dev/sdX bs=4M status=progress
```

## Usage

1. **Boot from the ISO**: Boot your target system from the USB drive
2. **Automatic Login**: The system will automatically log you in as the `installer` user
3. **Network Access**: ZeroTier will automatically connect to your network
4. **SSH Access**: You can SSH into the installer using your configured keys
5. **ZFS Tools**: All ZFS utilities are available for partitioning and setup

## Default Configuration

- **Username**: `installer` (auto-login enabled)
- **Shell**: Fish shell with basic configuration
- **Sudo**: Passwordless sudo access for the installer user
- **SSH**: Enabled with key-based authentication only
- **Timezone**: UTC
- **Locale**: en_US.UTF-8

## Customization

You can customize the installer by modifying the system configuration:

```nix
nixfigs.isoImage = {
  enable = true;
  isoName = "custom-installer";
  includeZeroTier = true;
  includeZFS = true;
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"
  ];
  extraPackages = with pkgs; [
    # Add additional packages here
    firefox
    git
  ];
};
```

## Troubleshooting

### ZeroTier not connecting
- Check that your network ID is correct in the secrets file
- Verify the ZeroTier service is running: `systemctl status zerotierone`
- Check network status: `zerotier-cli listnetworks`

### SSH access issues
- Verify your SSH keys are properly configured in the secrets file
- Check SSH service status: `systemctl status sshd`
- Test SSH connection: `ssh installer@<ip-address>`

### ZFS issues
- Ensure the target system supports ZFS
- Check available pools: `zpool list`
- Import pools if needed: `zpool import`

## Security Notes

- The installer ISO contains your ZeroTier network credentials
- SSH keys are embedded in the ISO - keep it secure
- The installer user has full sudo access
- Consider the ISO as sensitive material