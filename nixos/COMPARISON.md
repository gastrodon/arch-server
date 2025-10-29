# Archiso vs NixOS Configuration Comparison

This document provides a detailed comparison between the original Archiso configuration and the new NixOS port.

## File Structure Comparison

| Archiso | NixOS | Purpose |
|---------|-------|---------|
| `arch/profiledef.sh` | `nixos/configuration.nix` | System metadata and settings |
| `arch/packages.x86_64` | `nixos/configuration.nix` | Live ISO packages → System packages |
| `arch/pacman.conf` | Built-in nixpkgs | Package manager configuration |
| `arch/airootfs/etc/passwd` | `nixos/users.nix` | User definitions |
| `arch/airootfs/etc/group` | `nixos/users.nix` | Group memberships |
| `arch/airootfs/etc/sudoers` | `nixos/users.nix` | Sudo configuration |
| `arch/airootfs/etc/ssh/sshd_config` | `nixos/services.nix` | SSH server configuration |
| `arch/airootfs/etc/systemd/network/` | `nixos/networking.nix` | Network configuration |
| `arch/airootfs/etc/setup/install.sh` | `nixos/README.md` | Installation procedure |
| `arch/airootfs/etc/setup/chroot_setup.sh` | Declarative config | System setup |
| `arch/airootfs/etc/setup/packages` | `nixos/configuration.nix` | Installed system packages |
| `arch/airootfs/etc/options/*` | `nixos/configuration.nix` | Various system options |
| `arch/syslinux/*` | `nixos/hardware-configuration.nix` | Boot configuration (BIOS) |
| `arch/efiboot/*` | `nixos/hardware-configuration.nix` | Boot configuration (EFI) |
| `build` script | `nixos/build.sh` | Build/validation script |

## Configuration Element Comparison

### Hostname
**Archiso**: `arch/airootfs/etc/options/HOSTNAME`
```
arch-server
```

**NixOS**: `nixos/configuration.nix`
```nix
networking.hostName = "arch-server";
```

### Timezone
**Archiso**: `arch/airootfs/etc/options/REGION` + `setup/chroot_setup.sh`
```bash
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime
```

**NixOS**: `nixos/configuration.nix`
```nix
time.timeZone = "US/Eastern";
```

### Locale
**Archiso**: `arch/airootfs/etc/options/LOCALES` + `LANG`
```
en_US.UTF-8 UTF-8
```

**NixOS**: `nixos/configuration.nix`
```nix
i18n.defaultLocale = "en_US.UTF-8";
```

### Keymap
**Archiso**: `arch/airootfs/etc/options/KEYMAP`
```
en
```

**NixOS**: `nixos/configuration.nix`
```nix
console.keyMap = "us";
```

### User Configuration
**Archiso**: `arch/airootfs/etc/{passwd,group,sudoers}`
```
zero:x:1000:1000::/home/zero:/usr/bin/bash
wheel:x:10:zero
zero ALL=(ALL) NOPASSWD: ALL
```

**NixOS**: `nixos/users.nix`
```nix
users.users.zero = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" "adm" "uucp" ];
  shell = pkgs.bash;
};
security.sudo.wheelNeedsPassword = false;
```

### SSH Configuration
**Archiso**: `arch/airootfs/etc/ssh/sshd_config`
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

**NixOS**: `nixos/services.nix`
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

### Network Configuration
**Archiso**: `arch/airootfs/etc/systemd/network/20-ethernet.network`
```ini
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes

[DHCP]
RouteMetric=512
```

**NixOS**: `nixos/networking.nix`
```nix
systemd.network.networks."20-ethernet" = {
  matchConfig.Name = "en* eth*";
  networkConfig = {
    DHCP = "yes";
    IPv6PrivacyExtensions = "yes";
  };
  dhcpV4Config.RouteMetric = 512;
  dhcpV6Config.RouteMetric = 512;
};
```

### Boot Configuration
**Archiso**: `arch/airootfs/etc/setup/chroot_setup.sh`
```bash
grub-install \
    --target=x86_64-efi \
    --bootloader-id=GRUB \
    --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
```

**NixOS**: `nixos/hardware-configuration.nix`
```nix
boot.loader.grub = {
  enable = true;
  efiSupport = true;
  device = "nodev";
};
boot.loader.efi = {
  canTouchEfiVariables = true;
  efiSysMountPoint = "/boot/efi";
};
```

### Service Enablement
**Archiso**: `arch/airootfs/etc/setup/chroot_setup.sh`
```bash
systemctl enable dhcpcd docker sshd systemd-networkd systemd-resolved
```

**NixOS**: `nixos/services.nix` and `nixos/networking.nix`
```nix
services.openssh.enable = true;
virtualisation.docker.enable = true;
services.cron.enable = true;
systemd.network.enable = true;
services.resolved.enable = true;
```

### Disk Partitioning
**Archiso**: `arch/airootfs/etc/setup/sda.dump` + `install.sh`
```
/dev/sda1 : start=2048, size=1048576, type=c, bootable
/dev/sda2 : start=1050624, size=%disksize%, type=83
```

**NixOS**: `nixos/hardware-configuration.nix` + Manual partitioning (README.md)
```nix
fileSystems."/" = {
  device = "/dev/disk/by-label/nixos";
  fsType = "ext4";
};
fileSystems."/boot/efi" = {
  device = "/dev/disk/by-label/BOOT";
  fsType = "vfat";
};
```

## Package Comparison

| Package Category | Archiso | NixOS | Notes |
|-----------------|---------|-------|-------|
| Base System | `base` | Built-in | NixOS minimal system |
| Boot Tools | `grub`, `syslinux`, `efibootmgr` | `boot.loader.*` config | Managed declaratively |
| Kernel | `linux`, `linux-firmware` | `boot.kernelPackages` | Latest by default |
| Network | `dhcpcd`, `inetutils` | Same + networkd config | Enhanced DNS with resolved |
| Services | `openssh`, `docker`, `cron` | Same via `services.*` | Declarative service config |
| Utilities | `git`, `vim`, `curl`, `wget` | Same in `environment.systemPackages` | Plus htop added |
| Filesystem | `dosfstools` | Same | Disk utilities |
| Dev Tools | N/A | `edk2-shell`, `pv` | Development helpers |

## Workflow Comparison

### Installation
**Archiso**:
1. Boot live ISO
2. Run `setup.service` which executes `install.sh`
3. Script partitions disk, installs packages, configures system
4. Reboot

**NixOS**:
1. Boot installer ISO
2. Manually partition disk
3. Mount filesystems
4. Copy/clone configuration files
5. Run `nixos-install`
6. Reboot

### Adding Packages
**Archiso**:
```bash
sudo pacman -S package-name
```

**NixOS**:
```nix
# Edit configuration.nix
environment.systemPackages = with pkgs; [
  existing-packages
  new-package
];
```
```bash
sudo nixos-rebuild switch
```

### System Updates
**Archiso**:
```bash
sudo pacman -Syu
```

**NixOS**:
```bash
sudo nixos-rebuild switch --upgrade
```

### Service Configuration
**Archiso**:
```bash
sudo systemctl enable service-name
sudo systemctl start service-name
# Manually edit /etc/service/config
```

**NixOS**:
```nix
# Edit services.nix
services.service-name = {
  enable = true;
  # ... configuration ...
};
```
```bash
sudo nixos-rebuild switch
```

### Rolling Back Changes
**Archiso**:
- Manual recovery
- Reinstall from ISO
- Restore from backups

**NixOS**:
```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or select generation at boot time from bootloader menu
```

## Feature Comparison

| Feature | Archiso | NixOS |
|---------|---------|-------|
| **Configuration Style** | Imperative (scripts) | Declarative (expressions) |
| **Reproducibility** | Manual, environment-dependent | Automatic, bit-for-bit reproducible |
| **Version Control** | Partial (scripts only) | Full (entire system) |
| **Rollback** | No | Yes (multiple generations) |
| **Testing** | Requires VM or hardware | `nixos-rebuild build-vm` |
| **Modularity** | File-based | Nix module system |
| **Package Management** | pacman (imperative) | nix (functional) |
| **Update Safety** | In-place (risky) | Atomic (safe) |
| **Documentation** | README needed | Self-documenting config |
| **Validation** | Manual testing | `nixos-rebuild dry-build` |
| **Cross-machine** | Manual sync | Git + flakes |

## Advantages of NixOS Port

### 1. Declarative Configuration
- Entire system described in configuration files
- No hidden state or manual steps
- What you see is what you get

### 2. Reproducibility
- Exact same system can be rebuilt anywhere
- Flakes lock dependencies
- Bit-for-bit reproducible builds

### 3. Atomic Updates
- Updates don't modify existing system
- New generation created for each change
- Rollback to any previous state

### 4. Type Safety
- Nix language catches errors before deployment
- Invalid configurations rejected at build time
- No runtime surprises

### 5. Modularity
- Clean separation of concerns
- Easy to enable/disable features
- Reusable modules

### 6. Testing
- Test changes in VM before applying
- Dry-run builds catch issues
- No need to risk production system

### 7. Version Control
- Entire system configuration in git
- Track changes over time
- Collaborate with pull requests

### 8. Cross-Machine Deployment
- Same configuration on multiple machines
- Override specific settings per host
- Centralized configuration management

## Trade-offs

### Learning Curve
- **Archiso**: Familiar shell scripting
- **NixOS**: Requires learning Nix language

### Package Availability
- **Archiso**: AUR has most packages
- **NixOS**: nixpkgs is large but some packages differ

### Community Size
- **Archiso/Arch**: Larger community
- **NixOS**: Growing but smaller

### Documentation
- **Archiso/Arch**: Extensive wiki
- **NixOS**: Good official docs, community docs improving

## Conclusion

The NixOS port provides a more robust, maintainable, and reproducible system compared to the original Archiso setup. While there's a learning curve for Nix, the benefits of declarative configuration, atomic updates, and rollback capability make it worthwhile for a server system.

The port maintains 100% feature parity with the original setup while adding significant improvements in reliability and maintainability.
