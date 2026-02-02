# modules/common/network.nix
# Network configuration (NetworkManager + firewall)
{ pkgs, host, ... }:
{
  networking = {
    # Hostname is set from host variable
    hostName = "${host}";

    # NetworkManager for easy WiFi/VPN management
    networkmanager.enable = true;

    # DNS servers (Cloudflare + Google for reliability)
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];

    # Basic firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
      allowedUDPPorts = [ ];
    };
  };

  # NetworkManager applet for system tray
  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
