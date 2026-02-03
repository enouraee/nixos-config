# modules/theme/stylix-default.nix
# Global Stylix theming - applies to all hosts by default
# Based on nixy's theming approach (anotherhadi/nixy)
#
# Override options per-host by setting stylix.* in your host config
{ lib, pkgs, config, ... }:

let
  # Default wallpaper path (relative to flake root)
  defaultWallpaper = ../../assets/wallpapers/a-street-in-the-dark.png;
in
{
  # Theme customization options (can be overridden per-host)
  options.theme = lib.mkOption {
    type = lib.types.attrs;
    default = {
      rounding = 12;
      gaps-in = 8;
      gaps-out = 16;
      active-opacity = 0.95;
      inactive-opacity = 0.90;
      blur = true;
      border-size = 2;
      animation-speed = "medium"; # "fast" | "medium" | "slow"
    };
    description = "Theme configuration options for window manager styling";
  };

  config = {
    stylix = {
      enable = true;

      # Dark polarity
      polarity = "dark";

      # Default wallpaper (use local file from repo)
      image = defaultWallpaper;

      # Base16 color scheme - Catppuccin Macchiato (neutral dark theme)
      # See https://tinted-theming.github.io/tinted-gallery/ for more schemes
      base16Scheme = {
        base00 = "24273a"; # Default Background
        base01 = "1e2030"; # Lighter Background (status bars, line numbers)
        base02 = "363a4f"; # Selection Background
        base03 = "494d64"; # Comments, Invisibles, Line Highlighting
        base04 = "5b6078"; # Dark Foreground (status bars)
        base05 = "cad3f5"; # Default Foreground, Caret, Delimiters, Operators
        base06 = "f4dbd6"; # Light Foreground (rarely used)
        base07 = "b7bdf8"; # Light Background (rarely used)
        base08 = "ed8796"; # Variables, XML Tags, Markup Link Text, Diff Deleted
        base09 = "f5a97f"; # Integers, Boolean, Constants, XML Attributes
        base0A = "eed49f"; # Classes, Markup Bold, Search Text Background
        base0B = "a6da95"; # Strings, Inherited Class, Markup Code, Diff Inserted
        base0C = "8bd5ca"; # Support, Regular Expressions, Escape Characters
        base0D = "8aadf4"; # Functions, Methods, Attribute IDs, Headings
        base0E = "c6a0f6"; # Keywords, Storage, Selector, Markup Italic
        base0F = "f0c6c6"; # Deprecated, Opening/Closing Embedded Language Tags
      };

      # Cursor theme
      cursor = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
      };

      # Font configuration (preserves existing font choices from this repo)
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 11;
          desktop = 11;
          popups = 11;
          terminal = 11;
        };
      };

      # Auto-enable theming for various targets
      targets = {
        # GTK theming
        gtk.enable = true;

        # Console/TTY theming
        console.enable = true;

        # GRUB theming (if using GRUB)
        grub.enable = false; # We use systemd-boot

        # Chromium-based browser theming
        chromium.enable = true;
      };

      # Opacity settings
      opacity = {
        terminal = 0.95;
        applications = 1.0;
        desktop = 1.0;
        popups = 0.95;
      };
    };

    # Ensure stylix doesn't conflict with manual GTK settings
    # by letting stylix handle gtk/cursor configuration
  };
}
