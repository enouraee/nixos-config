# modules/common/xserver.nix
# X11/XWayland support and display manager
{ username, ... }:
{
  services = {
    xserver = {
      enable = true;
      # Keyboard layouts: English (us) + Persian (fa)
      # Switch with Alt+Caps Lock
      xkb.layout = "us,fa";
      xkb.options = "grp:alt_caps_toggle";
    };

    # Auto-login to Hyprland session
    displayManager.autoLogin = {
      enable = true;
      user = "${username}";
    };

    # Touchpad support
    libinput = {
      enable = true;
    };
  };

  # Prevent getting stuck at shutdown
  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}
