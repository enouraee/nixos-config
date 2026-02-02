# modules/home/hyprland/hyprland.nix
# Core Hyprland configuration and packages
{ pkgs, ... }:
{
  # Hyprland-related packages
  home.packages = with pkgs; [
    # Wallpaper daemon
    swww

    # Screenshot tools
    grimblast
    grim
    slurp

    # Color picker
    hyprpicker

    # Clipboard management
    wl-clip-persist
    wl-clipboard
    cliphist

    # Screen recording
    wf-recorder

    # Core Wayland libraries
    glib
    wayland

    # Directory environment
    direnv
  ];

  # Ensure xdg-desktop-autostart is triggered
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];

  # Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;       # Use system Hyprland
    portalPackage = null; # Use system portal

    xwayland = {
      enable = true;      # Run X11 apps under Wayland
    };

    systemd.enable = true; # Integrate with systemd user session
  };
}
