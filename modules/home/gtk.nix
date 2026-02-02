# modules/home/gtk.nix
# GTK theming
{ pkgs, ... }:
{
  # GTK packages
  home.packages = with pkgs; [
    adwaita-icon-theme
    papirus-icon-theme
  ];

  # GTK configuration
  gtk = {
    enable = true;

    # Theme
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # Icons
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # Font
    font = {
      name = "JetBrains Mono";
      size = 10;
    };

    # GTK3 settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    # GTK4 settings
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Cursor
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Qt theming (use GTK theme)
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
