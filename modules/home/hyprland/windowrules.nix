# modules/home/hyprland/windowrules.nix
# Hyprland window rules
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Float certain windows
      "float on, match:class ^(imv)$"                        # Image viewer
      "float on, match:class ^(mpv)$"                        # Video player
      "float on, match:class ^(pavucontrol)$"                # Volume control
      "float on, match:class ^(nm-connection-editor)$"       # Network manager
      "float on, match:class ^(org.gnome.Calculator)$"       # Calculator
      "float on, match:class ^(file-roller)$"                # Archive manager
      "float on, match:title ^(Picture-in-Picture)$"         # PiP windows

      # Pin PiP
      "pin on, match:title ^(Picture-in-Picture)$"

      # Workspace assignments (customize as needed)
      # "workspace 1, match:class ^(firefox)$"
      # "workspace 2, match:class ^(kitty)$"
      # "workspace 3, match:class ^(code)$"
      # "workspace 10, match:class ^(discord)$"

      # Idle inhibit for video
      "idle_inhibit focus, match:class ^(mpv)$"
      "idle_inhibit fullscreen, match:class ^(firefox)$"
      "idle_inhibit fullscreen, match:class ^(google-chrome)$"

      # XWayland windows get no rounded corners
      "rounding 0, match:xwayland true"

      # No gaps when only one window
      "border_size 0, match:float false, match:workspace w[tv1]"
      "rounding 0, match:float false, match:workspace w[tv1]"
      "border_size 0, match:float false, match:workspace f[1]"
      "rounding 0, match:float false, match:workspace f[1]"
    ];

    layerrule = [
      # Dim around launcher
      "dim_around on, match:namespace ^(wofi)$"
    ];

    # No gaps when only one tiled window
    workspace = [
      "w[tv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];
  };
}
