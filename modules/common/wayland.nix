# modules/common/wayland.nix
# Hyprland compositor and XDG portals
{ pkgs, ... }:
{
  # Enable Hyprland window manager
  programs.hyprland = {
    enable = true;
  };

  # XDG Desktop Portal configuration
  # Required for file pickers, screenshots, screen sharing, etc.
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
    };

    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
