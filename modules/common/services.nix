# modules/common/services.nix
# System services (dbus, gvfs, udisks2, etc.)
{ pkgs, ... }:
{
  services = {
    # Virtual filesystem for file managers
    gvfs.enable = true;

    # GNOME services needed outside GNOME Desktop
    gnome = {
      gnome-keyring.enable = true;  # Credential storage
    };

    # D-Bus message bus
    dbus.enable = true;
    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
    ];

    # SSD TRIM support
    fstrim.enable = true;

    # Auto-mount USB drives
    udisks2.enable = true;

    # Docker daemon
    virtualisation.docker = {
      enable = true;
      # Optionally configure additional settings here (storage driver, extraOptions)
    };

    # Power management
    upower.enable = true;

    # Don't shutdown on short power button press
    logind.settings.Login = {
      HandlePowerKey = "ignore";
    };
  };
}
