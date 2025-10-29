# NixOS configuration ported from archiso
# This is the main system configuration file

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./networking.nix
      ./users.nix
      ./services.nix
    ];

  # System settings
  system.stateVersion = "24.05"; # Use latest stable

  # Hostname
  networking.hostName = "arch-server";

  # Timezone and locale
  time.timeZone = "US/Eastern";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Console keymap
  console.keyMap = "us";

  # System packages from packages.x86_64 and setup/packages
  environment.systemPackages = with pkgs; [
    # From packages.x86_64 (adapted for NixOS)
    dosfstools
    edk2-shell
    # grub is configured via boot.loader, not as a package
    memtest86plus
    pv
    # reflector is Arch-specific, mirrors are handled differently in NixOS
    syslinux

    # From setup/packages
    # cron is configured via services.cron
    dhcpcd
    # docker is configured via virtualisation.docker
    efibootmgr
    git
    inetutils
    # linux-firmware is included by default in NixOS
    # openssh is configured via services.openssh
    # sudo is included by default
    which

    # Additional useful tools
    vim
    curl
    wget
    htop
  ];

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages if needed
  nixpkgs.config.allowUnfree = true;
}
