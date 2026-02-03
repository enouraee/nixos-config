# modules/home/hyprland/variables.nix
# Environment variables for Wayland/Hyprland
{ lib, ... }:
{
  home.sessionVariables = {
    # ====== WAYLAND ======
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    # ====== TOOLKIT BACKENDS ======
    GDK_BACKEND = "wayland,x11";      # GTK apps
    QT_QPA_PLATFORM = "wayland;xcb";  # Qt apps
    SDL_VIDEODRIVER = "wayland";      # SDL apps
    CLUTTER_BACKEND = "wayland";      # Clutter apps

    # ====== QT THEMING ======
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_QPA_PLATFORMTHEME is managed by Stylix

    # ====== ELECTRON/CHROMIUM ======
    NIXOS_OZONE_WL = "1";             # Force Wayland for Electron apps
    MOZ_ENABLE_WAYLAND = "1";         # Firefox Wayland

    # ====== GPU ======
    # Uncomment for AMD GPU
    # WLR_RENDERER = "vulkan";

    # Uncomment for NVIDIA (may help with issues)
    # WLR_NO_HARDWARE_CURSORS = "1";
    # __GL_GSYNC_ALLOWED = "0";
    # __GL_VRR_ALLOWED = "0";
  };
}
