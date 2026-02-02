# modules/home/hyprland/default.nix
# Hyprland configuration entry point
{ ... }:
{
  imports = [
    ./hyprland.nix      # Core Hyprland setup
    ./settings.nix      # General settings (input, decorations, animations)
    ./binds.nix         # Keybindings
    ./windowrules.nix   # Window rules
    ./exec-once.nix     # Startup applications
    ./monitors.nix      # Monitor configuration
    ./variables.nix     # Environment variables
  ];
}
