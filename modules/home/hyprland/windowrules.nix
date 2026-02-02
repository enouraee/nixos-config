# modules/home/hyprland/windowrules.nix
# Hyprland window rules
{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Float certain windows
      "float, class:^(imv)$"                        # Image viewer
      "float, class:^(mpv)$"                        # Video player
      "float, class:^(pavucontrol)$"                # Volume control
      "float, class:^(nm-connection-editor)$"       # Network manager
      "float, class:^(org.gnome.Calculator)$"       # Calculator
      "float, class:^(file-roller)$"                # Archive manager
      "float, title:^(Picture-in-Picture)$"         # PiP windows

      # Pin PiP
      "pin, title:^(Picture-in-Picture)$"

      # Workspace assignments (customize as needed)
      # "workspace 1, class:^(firefox)$"
      # "workspace 2, class:^(kitty)$"
      # "workspace 3, class:^(code)$"
      # "workspace 10, class:^(discord)$"

      # Idle inhibit for video
      "idleinhibit focus, class:^(mpv)$"
      "idleinhibit fullscreen, class:^(firefox)$"
      "idleinhibit fullscreen, class:^(google-chrome)$"

      # XWayland windows get no rounded corners
      "rounding 0, xwayland:1"

      # No gaps when only one window
      "bordersize 0, floating:0, onworkspace:w[tv1]"
      "rounding 0, floating:0, onworkspace:w[tv1]"
      "bordersize 0, floating:0, onworkspace:f[1]"
      "rounding 0, floating:0, onworkspace:f[1]"
    ];

    layerrule = [
      # Dim around launcher
      "dimaround, wofi"
    ];

    # No gaps when only one tiled window
    workspace = [
      "w[tv1], gapsout:0, gapsin:0"
      "f[1], gapsout:0, gapsin:0"
    ];
  };
}
