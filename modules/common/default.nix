# modules/common/default.nix
# Main entry point for common modules - imported by all hosts
{ ... }:
{
  imports = [
    ./bootloader.nix    # Boot configuration (systemd-boot)
    ./hardware.nix      # Common hardware support
    ./network.nix       # NetworkManager + firewall
    ./audio.nix         # PipeWire audio stack
    ./wayland.nix       # Hyprland + XDG portals
    ./services.nix      # System services (dbus, udisks2, etc.)
    ./security.nix      # Security settings (sudo, pam, rtkit)
    ./system.nix        # Nix settings, locale, timezone
    ./user.nix          # User creation + home-manager
    ./fonts.nix         # System fonts
    ./xserver.nix       # X11/XWayland support + display manager
    ./scripts.nix       # Custom scripts (health-check, etc.)
  ];
}
