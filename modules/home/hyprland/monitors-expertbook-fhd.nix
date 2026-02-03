{ pkgs, ... }:
{
  # ExpertBook FHD (14" FHD panel) - set scale 1.0 for eDP-1
  wayland.windowManager.hyprland = {
    settings.monitor = [
      "eDP-1,1920x1080@60,0x0,1"
      ",preferred,auto,1"
    ];
  };
}
