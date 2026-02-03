# modules/home/gtk.nix
# GTK theming - Stylix handles theme/cursor, we only add extra packages/settings
{ pkgs, ... }:
{
  # Additional icon packages (Stylix handles base GTK theme)
  home.packages = with pkgs; [
    adwaita-icon-theme
    papirus-icon-theme
  ];

  # GTK configuration - let Stylix manage theme, we add extras
  gtk = {
    enable = true;

    # Icons (supplement Stylix's theming)
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # GTK3 extra settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    # GTK4 extra settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Cursor is managed by Stylix (home.pointerCursor)
  # Do not set home.pointerCursor here to avoid conflicts

  # Qt theming is managed by Stylix - do not set here to avoid conflicts
}
