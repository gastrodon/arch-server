# Migration Guide: Archiso to NixOS

This guide explains how to migrate from the archiso-based arch-server setup to the new NixOS configuration.

## Key Differences

### Philosophy
- **Archiso**: Imperative configuration using shell scripts
- **NixOS**: Declarative configuration using Nix expressions

### Package Management
- **Archiso**: Uses `pacman` for package management
- **NixOS**: Uses `nix` package manager with declarative package specifications

### System Configuration
- **Archiso**: Configuration scattered across multiple shell scripts and config files
- **NixOS**: Centralized, modular configuration in `.nix` files

### Updates
- **Archiso**: `pacman -Syu` updates packages in-place
- **NixOS**: `nixos-rebuild switch` creates a new system generation (can roll back)

## Configuration Mapping

### Packages

**Archiso (`packages.x86_64` and `setup/packages`):**
```
base
cron
dhcpcd
docker
git
grub
linux
openssh
```

**NixOS (`configuration.nix`):**
```nix
environment.systemPackages = with pkgs; [
  dhcpcd
  git
  vim
  curl
  # ... more packages
];

# Services are configured separately
services.openssh.enable = true;
virtualisation.docker.enable = true;
```

### Users and Groups

**Archiso (`airootfs/etc/passwd`, `group`, `sudoers`):**
```
zero:x:1000:1000::/home/zero:/usr/bin/bash
wheel:x:10:zero
zero ALL=(ALL) NOPASSWD: ALL
```

**NixOS (`users.nix`):**
```nix
users.users.zero = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" ];
  shell = pkgs.bash;
};
security.sudo.wheelNeedsPassword = false;
```

### Network Configuration

**Archiso (`airootfs/etc/systemd/network/20-ethernet.network`):**
```ini
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
```

**NixOS (`networking.nix`):**
```nix
systemd.network.networks."20-ethernet" = {
  matchConfig.Name = "en* eth*";
  networkConfig.DHCP = "yes";
};
```

### SSH Configuration

**Archiso (`airootfs/etc/ssh/sshd_config`):**
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

**NixOS (`services.nix`):**
```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
    PubkeyAuthentication = true;
  };
};
```

### Boot Configuration

**Archiso (`setup/chroot_setup.sh`):**
```bash
grub-install \
    --target=x86_64-efi \
    --bootloader-id=GRUB \
    --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
```

**NixOS (`hardware-configuration.nix`):**
```nix
boot.loader.grub = {
  enable = true;
  efiSupport = true;
  device = "nodev";
};
boot.loader.efi.canTouchEfiVariables = true;
```

### Locale and Timezone

**Archiso (`setup/chroot_setup.sh` + options files):**
```bash
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

**NixOS (`configuration.nix`):**
```nix
time.timeZone = "US/Eastern";
i18n.defaultLocale = "en_US.UTF-8";
```

### Service Enablement

**Archiso (`setup/chroot_setup.sh`):**
```bash
systemctl enable dhcpcd docker sshd systemd-networkd systemd-resolved
```

**NixOS (`services.nix` and `networking.nix`):**
```nix
services.openssh.enable = true;
virtualisation.docker.enable = true;
systemd.network.enable = true;
services.resolved.enable = true;
```

## Migration Steps

### 1. Backup Current System
Before migrating, back up any important data and configuration:
```bash
# Backup home directory
tar -czf /backup/home-zero.tar.gz /home/zero

# Backup any custom configurations
tar -czf /backup/etc-config.tar.gz /etc
```

### 2. Prepare Installation Media
Download the latest NixOS ISO from https://nixos.org/download.html

### 3. Partition Disk
The NixOS configuration expects a similar partition layout:
- `/dev/sda1`: EFI boot partition (512MB, FAT32)
- `/dev/sda2`: Root partition (ext4)

You can either:
- **Option A**: Keep existing partitions and reformat (DESTRUCTIVE)
- **Option B**: Dual boot by creating new partitions (if space available)

### 4. Install NixOS
Follow the installation instructions in `README.md`

### 5. Restore Data
After installation, restore your backed-up data:
```bash
# Restore home directory
cd /home/zero
sudo tar -xzf /backup/home-zero.tar.gz --strip-components=3

# Set ownership
sudo chown -R zero:users /home/zero
```

### 6. Migrate Custom Configurations

#### SSH Keys
```bash
mkdir -p /home/zero/.ssh
# Copy your authorized_keys file
sudo cp /backup/authorized_keys /home/zero/.ssh/
sudo chown -R zero:users /home/zero/.ssh
sudo chmod 700 /home/zero/.ssh
sudo chmod 600 /home/zero/.ssh/authorized_keys
```

#### Docker Containers/Volumes
If you have Docker data to migrate:
```bash
# Stop Docker on old system
sudo systemctl stop docker

# Copy Docker data
sudo rsync -avz /var/lib/docker/ /backup/docker/

# On new system (after Docker is installed)
sudo systemctl stop docker
sudo rsync -avz /backup/docker/ /var/lib/docker/
sudo systemctl start docker
```

## Common Tasks Comparison

### Installing Packages

**Archiso:**
```bash
sudo pacman -S package-name
```

**NixOS:**
```bash
# Option 1: Temporarily install
nix-shell -p package-name

# Option 2: Permanently install (add to configuration.nix)
# Then run:
sudo nixos-rebuild switch
```

### Updating System

**Archiso:**
```bash
sudo pacman -Syu
```

**NixOS:**
```bash
sudo nixos-rebuild switch --upgrade
```

### Viewing Logs

**Archiso:**
```bash
journalctl -xe
```

**NixOS:**
```bash
journalctl -xe  # Same!
```

### Managing Services

**Archiso:**
```bash
sudo systemctl start/stop/restart service-name
```

**NixOS:**
```bash
sudo systemctl start/stop/restart service-name  # Same!
# But enable services in configuration.nix instead of using systemctl enable
```

## Rollback Capability

One major advantage of NixOS is the ability to rollback:

```bash
# List all system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Rollback at boot time
# Just select a previous generation from the bootloader menu!
```

## Troubleshooting

### "Package not found"
- Search for packages: https://search.nixos.org/packages
- Package names may differ from Arch Linux

### "Service failed to start"
- Check configuration syntax: `sudo nixos-rebuild dry-build`
- View service logs: `sudo journalctl -u service-name`

### "Cannot find module"
- Ensure all imported modules exist
- Check paths in `imports = [ ... ]` in configuration.nix

### "Permission denied"
- NixOS uses a different permission model
- Some directories are read-only
- Check user group membership in `users.nix`

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Tutorial series
- [NixOS Wiki](https://nixos.wiki/)
- [Package Search](https://search.nixos.org/)
- [NixOS Discourse](https://discourse.nixos.org/)

## Getting Help

If you encounter issues during migration:
1. Check the NixOS manual for your specific use case
2. Search existing issues on NixOS GitHub
3. Ask on the NixOS Discourse forum
4. Join the NixOS community on Matrix/IRC
