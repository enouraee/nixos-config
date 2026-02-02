# modules/home/default.nix
# Main entry point for Home Manager modules
{ ... }:
{
  imports = [
    ./hyprland               # Hyprland window manager config
    ./zsh.nix                # Zsh shell + Oh-My-Zsh
    ./packages.nix           # User packages
    ./gtk.nix                # GTK theming
    ./kitty.nix              # Terminal emulator
    ./git.nix                # Git configuration
    ./xdg.nix                # XDG directories and mimes
  ];
}
