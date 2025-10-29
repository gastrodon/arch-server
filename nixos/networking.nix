# Network configuration
# Ported from airootfs/etc/systemd/network/20-ethernet.network

{ config, pkgs, ... }:

{
  # Network configuration
  networking = {
    # Enable networkd for systemd-networkd style configuration
    useNetworkd = true;
    useDHCP = false; # We'll configure per-interface
  };

  # systemd-networkd configuration
  systemd.network = {
    enable = true;

    # Match ethernet devices and configure DHCP
    networks."20-ethernet" = {
      matchConfig = {
        Name = "en* eth*";
      };
      networkConfig = {
        DHCP = "yes";
        IPv6PrivacyExtensions = "yes";
      };
      dhcpV4Config = {
        RouteMetric = 512;
      };
      dhcpV6Config = {
        RouteMetric = 512;
      };
    };
  };

  # Enable systemd-resolved for DNS
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    fallbackDns = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH
  };
}
