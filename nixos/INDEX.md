# NixOS Configuration - File Index

Quick reference guide to all files in this directory.

## 📖 Documentation (Start Here!)

### For New Users
1. **[QUICKSTART.md](QUICKSTART.md)** - 5-step installation guide for getting started quickly
2. **[README.md](README.md)** - Comprehensive documentation with detailed installation instructions

### For Archiso Users
3. **[MIGRATION.md](MIGRATION.md)** - Guide for migrating from the original Archiso setup
4. **[COMPARISON.md](COMPARISON.md)** - Detailed side-by-side comparison of Archiso vs NixOS

### For Understanding the Port
5. **[SUMMARY.md](SUMMARY.md)** - Overview of the port, architecture, and design decisions

## ⚙️ Configuration Files

### Core System Configuration
- **[configuration.nix](configuration.nix)** - Main system configuration file
  - System settings (hostname, locale, timezone)
  - Package list
  - Imports all other modules

### Modular Configuration
- **[hardware-configuration.nix](hardware-configuration.nix)** - Hardware and boot configuration
  - GRUB bootloader
  - Filesystem definitions
  - Kernel settings

- **[networking.nix](networking.nix)** - Network configuration
  - systemd-networkd setup
  - DHCP configuration
  - DNS and firewall settings

- **[users.nix](users.nix)** - User and permission configuration
  - User 'zero' definition
  - Group memberships
  - Sudo configuration

- **[services.nix](services.nix)** - System services
  - SSH daemon
  - Docker
  - Cron
  - NTP

## 🔧 Build Tools

- **[flake.nix](flake.nix)** - Nix flake for reproducible builds
  - Enables flake-based installation
  - Locks dependencies for reproducibility

- **[build.sh](build.sh)** - Build and validation helper script
  - Syntax checking
  - Build commands
  - Dry-build validation

## 🗂️ Other Files

- **[.gitignore](.gitignore)** - Git ignore rules for Nix build artifacts

## 📋 Quick Reference

### Which file do I read first?
- **Just want to install?** → [QUICKSTART.md](QUICKSTART.md)
- **Want detailed info?** → [README.md](README.md)
- **Coming from Archiso?** → [MIGRATION.md](MIGRATION.md)
- **Want to understand the differences?** → [COMPARISON.md](COMPARISON.md)

### Which file do I edit?
- **Add/remove packages** → [configuration.nix](configuration.nix)
- **Change boot settings** → [hardware-configuration.nix](hardware-configuration.nix)
- **Modify network settings** → [networking.nix](networking.nix)
- **Add/modify users** → [users.nix](users.nix)
- **Enable/configure services** → [services.nix](services.nix)

### How do I...?

| Task | File to Edit | After Editing |
|------|-------------|---------------|
| Add a package | configuration.nix | `sudo nixos-rebuild switch` |
| Change hostname | configuration.nix | `sudo nixos-rebuild switch` |
| Open firewall port | networking.nix | `sudo nixos-rebuild switch` |
| Add a user | users.nix | `sudo nixos-rebuild switch` |
| Enable a service | services.nix | `sudo nixos-rebuild switch` |
| Change timezone | configuration.nix | `sudo nixos-rebuild switch` |

## 🔢 File Statistics

```
Total Files: 12
- Configuration: 6 (.nix files)
- Documentation: 5 (.md files)
- Tools: 1 (.sh script)
- Other: 1 (.gitignore)

Lines of Configuration: ~200
Lines of Documentation: ~1000+
```

## 🎯 Feature Coverage

All features from the original Archiso configuration have been ported:
- ✅ System configuration (hostname, locale, timezone)
- ✅ User management (zero user with sudo)
- ✅ Network configuration (DHCP, DNS)
- ✅ Services (SSH, Docker, Cron)
- ✅ Boot configuration (GRUB with EFI)
- ✅ Package management (all original packages)
- ✅ Security settings (SSH, firewall, sudo)

## 🚀 Getting Started

1. Read [QUICKSTART.md](QUICKSTART.md) or [README.md](README.md)
2. Boot NixOS installer ISO
3. Partition your disk
4. Copy these files to `/mnt/etc/nixos/`
5. Run `nixos-install`
6. Reboot and enjoy!

## 📚 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Package Search](https://search.nixos.org/)
- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Discourse](https://discourse.nixos.org/)
