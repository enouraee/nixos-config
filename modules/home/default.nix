# modules/home/default.nix
# Main entry point for Home Manager modules
{ host, ... }:
{
  imports = [
    ./hyprland               # Hyprland window manager config
    ./zsh.nix                # Zsh shell + Oh-My-Zsh
    ./packages.nix           # User packages
    ./gtk.nix                # GTK theming
    ./kitty.nix              # Terminal emulator
    ./git.nix                # Git configuration
    ./xdg.nix                # XDG directories and mimes
  ] ++ (if host == "expertbook" then [ ./hyprland/monitors-expertbook-fhd.nix ] else []);

  # Disable Stylix's Hyprland target to avoid conflicts with our custom settings
  # We manage borders, shadows, gaps, colors, etc. manually in hyprland/settings.nix
  stylix.targets.hyprland.enable = false;
}
