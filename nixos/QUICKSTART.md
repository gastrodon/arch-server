# Quick Start Guide

Get your NixOS arch-server system up and running in minutes.

## Prerequisites

- A computer with x86_64 architecture
- NixOS installation media (USB stick or ISO)
- Basic familiarity with Linux command line

## Installation (5 steps)

### 1. Boot NixOS Installer
Boot from the NixOS installation media.

### 2. Partition and Format
```bash
# Partition the disk
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 513MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary ext4 513MiB 100%

# Format partitions
mkfs.fat -F 32 -n BOOT /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

# Mount filesystems
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot/efi
mount /dev/disk/by-label/BOOT /mnt/boot/efi
```

### 3. Install Configuration
```bash
# Clone configuration
cd /mnt
nix-shell -p git
git clone https://github.com/gastrodon/arch-server.git
cp -r arch-server/nixos /mnt/etc/nixos

# Or copy manually if you have the files locally
mkdir -p /mnt/etc/nixos
cp nixos/* /mnt/etc/nixos/
```

### 4. Install NixOS
```bash
# Install system
nixos-install

# Set password for user 'zero'
nixos-enter
passwd zero
exit
```

### 5. Reboot
```bash
reboot
```

## Post-Installation

### Set Up SSH Access
```bash
# On the server
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add your public key
nano ~/.ssh/authorized_keys
# Paste your public key, save and exit

chmod 600 ~/.ssh/authorized_keys
```

### Verify Services
```bash
# Check SSH
sudo systemctl status sshd

# Check Docker
sudo systemctl status docker
docker ps

# Check network
ip addr
ping -c 3 google.com
```

## Common Tasks

### Install Additional Packages
Edit `/etc/nixos/configuration.nix` and add packages:
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  neovim
  tmux
  htop
];
```

Then apply:
```bash
sudo nixos-rebuild switch
```

### Update System
```bash
sudo nixos-rebuild switch --upgrade
```

### Open Firewall Ports
Edit `/etc/nixos/networking.nix`:
```nix
networking.firewall.allowedTCPPorts = [ 22 80 443 ];
```

Then apply:
```bash
sudo nixos-rebuild switch
```

### Add Docker Containers
Docker works the same as on any Linux system:
```bash
docker run -d -p 80:80 nginx
```

Or declare in configuration for reproducibility (advanced):
```nix
virtualisation.oci-containers.containers.nginx = {
  image = "nginx:latest";
  ports = [ "80:80" ];
};
```

## Troubleshooting

### Can't login as zero
Make sure you set a password during installation:
```bash
# From installer
nixos-enter
passwd zero
```

### Network not working
Check network interface name:
```bash
ip link
```

Update `/etc/nixos/networking.nix` if needed.

### Service won't start
Check logs:
```bash
sudo journalctl -u service-name -f
```

### System won't boot
Select previous generation from bootloader menu.

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [MIGRATION.md](MIGRATION.md) if coming from Arch Linux
- Explore [NixOS options](https://search.nixos.org/options)
- Join the [NixOS community](https://nixos.org/community/)

## Getting Help

- Documentation: https://nixos.org/manual/nixos/stable/
- Forum: https://discourse.nixos.org/
- Chat: Matrix #nixos:nixos.org
- Package search: https://search.nixos.org/
