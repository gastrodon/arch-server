# Hardware configuration
# Ported from archiso disk partitioning scheme (sda.dump)

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # Boot loader configuration
  # Uses GRUB for both BIOS and EFI boot
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = false;
    device = "nodev"; # Don't install GRUB to MBR when using EFI
    useOSProber = true;
  };
  
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  # Also enable systemd-boot as an alternative (commented by default)
  # boot.loader.systemd-boot.enable = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # initrd configuration - minimal hooks similar to archiso
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Filesystem configuration
  # Based on sda.dump: sda1 (EFI), sda2 (root)
  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Networking hardware
  networking.useDHCP = lib.mkDefault true;

  # CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
