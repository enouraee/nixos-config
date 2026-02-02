# modules/home/hyprland/monitors.nix
# Monitor configuration
{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    # Default: auto-detect monitors
    settings.monitor = [ ",preferred,auto,auto" ];

    # Allow external monitor config files
    # Create ~/.config/hypr/monitors.conf for custom setup
    extraConfig = ''
      # hyprlang noerror true
        source = ~/.config/hypr/monitors.conf
        source = ~/.config/hypr/workspaces.conf
      # hyprlang noerror false
    '';
  };

  # GUI tool for monitor arrangement
  home.packages = with pkgs; [ nwg-displays ];
}
