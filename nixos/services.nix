# Services configuration
# Ported from chroot_setup.sh and systemd service enables

{ config, pkgs, ... }:

{
  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      ChallengeResponseAuthentication = false;
      UsePAM = true;
      PrintMotd = false;
    };
    extraConfig = ''
      AuthorizedKeysFile .ssh/authorized_keys
    '';
  };

  # Docker service
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      # Add cron jobs here as needed
    ];
  };

  # Enable NTP for time synchronization
  services.timesyncd.enable = true;

  # systemd-networkd (enabled in networking.nix)
  # systemd-resolved (enabled in networking.nix)

  # Enable dhcpcd as backup/alternative
  # networking.dhcpcd.enable = true;
}
