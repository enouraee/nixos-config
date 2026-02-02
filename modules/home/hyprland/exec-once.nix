# modules/home/hyprland/exec-once.nix
# Startup applications
{ ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    # ====== ENVIRONMENT ======
    # Export environment for systemd and dbus
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

    # ====== AUTHENTICATION ======
    # Polkit agent for privilege escalation
    "/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1 &"

    # ====== SYSTEM TRAY ======
    "nm-applet &"                      # Network manager

    # ====== CLIPBOARD ======
    "wl-clip-persist --clipboard both &"
    "wl-paste --watch cliphist store &"

    # ====== BAR & NOTIFICATIONS ======
    "waybar &"
    "mako &"

    # ====== AUTOMOUNT ======
    "udiskie --automount --notify --smart-tray &"

    # ====== WALLPAPER ======
    # Initialize wallpaper daemon
    "swww-daemon &"
    # Set default wallpaper (create ~/.config/wallpaper.png or change path)
    "sleep 1 && swww img ~/.config/wallpaper.png 2>/dev/null || true"

    # ====== CURSOR ======
    "hyprctl setcursor Adwaita 24 &"
  ];
}
