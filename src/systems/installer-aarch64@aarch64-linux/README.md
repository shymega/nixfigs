# NixOS Installer ISO Configuration (aarch64)

This directory contains the configuration for building a generic NixOS installer ISO for aarch64 architecture with the following features:

## Features

- **ZFS Support**: Full ZFS utilities and kernel support for advanced storage management
- **ZeroTier Networking**: Automatic connection to your ZeroTier network for remote access
- **SSH Access**: Pre-configured SSH access with your public keys
- **ARM64 Optimized**: Specifically configured for aarch64 architecture
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

1. **Boot from the ISO**: Boot your target ARM64 system from the USB drive
2. **Automatic Login**: The system will automatically log you in as the `installer` user
3. **Network Access**: ZeroTier will automatically connect to your network
4. **SSH Access**: You can SSH into the installer using your configured keys
5. **ZFS Tools**: All ZFS utilities are available for partitioning and setup

## ARM64 Specific Features

- **Device Tree Support**: Includes device tree compiler (dtc) for ARM systems
- **U-Boot Tools**: Includes U-Boot utilities for ARM bootloaders
- **ARM Hardware Detection**: Optimized hardware detection for ARM systems
- **Serial Console**: Configured for common ARM serial console interfaces

## Default Configuration

- **Username**: `installer` (auto-login enabled)
- **Shell**: Fish shell with basic configuration
- **Sudo**: Passwordless sudo access for the installer user
- **SSH**: Enabled with key-based authentication only
- **Timezone**: UTC
- **Locale**: en_US.UTF-8
- **Console**: Configured for both serial and video output

## Customization

You can customize the installer by modifying the system configuration:

```nix
nixfigs.isoImage = {
  enable = true;
  isoName = "custom-installer-aarch64";
  includeZeroTier = true;
  includeZFS = true;
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"
  ];
  extraPackages = with pkgs; [
    # Add additional ARM64-specific packages here
    dtc
    u-boot-tools
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
- Ensure the target ARM64 system supports ZFS
- Check available pools: `zpool list`
- Import pools if needed: `zpool import`

### ARM64 Specific Issues
- **Boot Issues**: Check if the system supports UEFI or requires U-Boot
- **Device Tree**: Some ARM systems may require specific device tree files
- **Serial Console**: Use `screen /dev/ttyS0 115200` or similar for serial access

## Security Notes

- The installer ISO contains your ZeroTier network credentials
- SSH keys are embedded in the ISO - keep it secure
- The installer user has full sudo access
- Consider the ISO as sensitive material