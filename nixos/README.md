# NixOS Configuration for arch-server

This directory contains the NixOS configuration ported from the original archiso setup.

## Overview

The configuration has been split into modular files for better organization:

- **`configuration.nix`** - Main system configuration (hostname, locale, packages)
- **`hardware-configuration.nix`** - Boot loader and filesystem configuration
- **`networking.nix`** - Network and firewall settings
- **`users.nix`** - User and group configuration
- **`services.nix`** - System services (SSH, Docker, Cron)
- **`flake.nix`** - Nix flake for reproducible builds

## Key Features

### System Configuration
- **Hostname**: `arch-server`
- **Timezone**: US/Eastern
- **Locale**: en_US.UTF-8
- **Keymap**: US

### Boot Configuration
- **Bootloader**: GRUB with EFI support
- **Kernel**: Latest Linux kernel
- **Partition scheme**: EFI boot partition + ext4 root partition

### User Configuration
- **User**: `zero` (replaces the archiso zero user)
- **Groups**: wheel, docker, adm, uucp
- **Sudo**: Passwordless sudo for wheel group
- **Root**: Login disabled

### Networking
- **DHCP**: Enabled on all ethernet interfaces (en*, eth*)
- **IPv6**: Privacy extensions enabled
- **DNS**: systemd-resolved with fallback to 8.8.8.8, 8.8.4.4, 1.1.1.1
- **Firewall**: Enabled with SSH (port 22) allowed

### Services
- **SSH**: Enabled, key-based auth only, root login disabled
- **Docker**: Enabled and auto-start
- **Cron**: Enabled
- **NTP**: Time synchronization enabled

### System Packages
All packages from the original archiso configuration:
- System utilities: git, vim, curl, wget, htop
- Disk tools: dosfstools, efibootmgr
- Network: dhcpcd, inetutils, openssh
- Development: docker

## Installation

### Option 1: Fresh Installation

1. **Boot NixOS installer ISO**
   ```bash
   # Download from https://nixos.org/download.html
   ```

2. **Partition the disk** (matching original sda.dump layout)
   ```bash
   # Create GPT partition table
   parted /dev/sda -- mklabel gpt
   
   # Create EFI partition (512MB)
   parted /dev/sda -- mkpart ESP fat32 1MiB 513MiB
   parted /dev/sda -- set 1 esp on
   
   # Create root partition (rest of disk)
   parted /dev/sda -- mkpart primary ext4 513MiB 100%
   
   # Format partitions
   mkfs.fat -F 32 -n BOOT /dev/sda1
   mkfs.ext4 -L nixos /dev/sda2
   ```

3. **Mount filesystems**
   ```bash
   mount /dev/disk/by-label/nixos /mnt
   mkdir -p /mnt/boot/efi
   mount /dev/disk/by-label/BOOT /mnt/boot/efi
   ```

4. **Copy configuration**
   ```bash
   mkdir -p /mnt/etc/nixos
   cp -r nixos/* /mnt/etc/nixos/
   ```

5. **Install NixOS**
   ```bash
   nixos-install
   ```

6. **Set user password**
   ```bash
   nixos-enter
   passwd zero
   exit
   ```

7. **Reboot**
   ```bash
   reboot
   ```

### Option 2: Using Flakes (Recommended)

1. **Boot NixOS installer and setup partitions** (same as Option 1, steps 1-3)

2. **Clone or copy this configuration**
   ```bash
   # If you have network access
   nix-shell -p git
   git clone https://github.com/gastrodon/arch-server.git /mnt/etc/nixos/arch-server
   cd /mnt/etc/nixos/arch-server/nixos
   ```

3. **Install using flakes**
   ```bash
   nixos-install --flake .#arch-server
   ```

4. **Set user password and reboot** (same as Option 1, steps 6-7)

### Option 3: Rebuild Existing NixOS System

If you're already running NixOS and want to apply this configuration:

```bash
# Copy configuration files
sudo cp -r nixos/* /etc/nixos/

# Rebuild and switch
sudo nixos-rebuild switch
```

## Post-Installation

### Set up SSH keys for the zero user
```bash
mkdir -p /home/zero/.ssh
# Add your public keys to /home/zero/.ssh/authorized_keys
chmod 700 /home/zero/.ssh
chmod 600 /home/zero/.ssh/authorized_keys
chown -R zero:users /home/zero/.ssh
```

### Configure Docker
Docker should start automatically. Verify with:
```bash
sudo systemctl status docker
docker ps
```

## Customization

### Modify Packages
Edit `configuration.nix` and add/remove packages from `environment.systemPackages`.

### Adjust Network Settings
Edit `networking.nix` to modify DHCP settings, firewall rules, or DNS configuration.

### Add More Users
Edit `users.nix` to add additional users or modify the zero user settings.

### Configure Services
Edit `services.nix` to enable/disable services or add new ones.

After making changes, rebuild:
```bash
sudo nixos-rebuild switch
```

## Migration Notes

This configuration replicates the functionality of the original archiso setup:

### Equivalent Mappings

| Archiso File/Setting | NixOS Configuration |
|---------------------|---------------------|
| `profiledef.sh` | `configuration.nix` (system settings) |
| `packages.x86_64` | `configuration.nix` (environment.systemPackages) |
| `pacman.conf` | Managed by nixpkgs |
| `airootfs/etc/passwd` | `users.nix` |
| `airootfs/etc/group` | `users.nix` (extraGroups) |
| `airootfs/etc/sudoers` | `users.nix` (wheelNeedsPassword) |
| `airootfs/etc/ssh/sshd_config` | `services.nix` (services.openssh) |
| `systemd/network/20-ethernet.network` | `networking.nix` (systemd.network) |
| `setup/install.sh` | Installation procedure (see above) |
| `setup/chroot_setup.sh` | Declaratively configured in NixOS |

### Key Differences

1. **Declarative vs Imperative**: NixOS uses declarative configuration instead of shell scripts
2. **Package Management**: Nix package manager instead of pacman
3. **Reproducibility**: Flakes ensure exact reproducibility across installations
4. **Atomic Updates**: System updates are atomic and can be rolled back
5. **No Manual Setup Script**: The setup is part of the configuration, not a separate script

## Troubleshooting

### Check configuration syntax
```bash
sudo nixos-rebuild dry-build
```

### View system logs
```bash
sudo journalctl -xe
```

### Roll back to previous generation
```bash
sudo nixos-rebuild switch --rollback
```

### List all generations
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Package Search](https://search.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Discourse](https://discourse.nixos.org/)
