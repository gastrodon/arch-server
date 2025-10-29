# User configuration
# Ported from airootfs/etc/passwd, group, and sudoers

{ config, pkgs, ... }:

{
  # User configuration
  users.users.zero = {
    isNormalUser = true;
    description = "Zero";
    extraGroups = [ 
      "wheel"      # sudo access
      "docker"     # docker access
      "adm"        # system administration
      "uucp"       # serial port access
    ];
    home = "/home/zero";
    shell = pkgs.bash;
    # Password must be set after installation
    # Use: passwd zero
  };

  # Allow wheel group to use sudo without password
  security.sudo.wheelNeedsPassword = false;

  # Disable root login
  users.users.root.hashedPassword = "!";

  # Initial empty password for zero user (must change on first login)
  # users.users.zero.initialPassword = "";
}
