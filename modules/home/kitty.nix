# modules/home/kitty.nix
# Kitty terminal emulator
{ ... }:
{
  programs.kitty = {
    enable = true;

    settings = {
      # Font
      font_family = "JetBrainsMono Nerd Font";
      font_size = 11;
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";

      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 0;

      # Scrollback
      scrollback_lines = 10000;

      # Window
      window_padding_width = 10;
      confirm_os_window_close = 0;

      # Bell
      enable_audio_bell = false;

      # URL handling
      url_style = "curly";
      detect_urls = true;

      # Background
      background_opacity = "0.95";

      # ====== COLORS (Catppuccin Macchiato) ======
      foreground = "#cad3f5";
      background = "#24273a";
      selection_foreground = "#24273a";
      selection_background = "#f4dbd6";

      # Cursor
      cursor = "#f4dbd6";
      cursor_text_color = "#24273a";

      # Normal colors
      color0 = "#494d64";   # Black
      color1 = "#ed8796";   # Red
      color2 = "#a6da95";   # Green
      color3 = "#eed49f";   # Yellow
      color4 = "#8aadf4";   # Blue
      color5 = "#f5bde6";   # Magenta
      color6 = "#8bd5ca";   # Cyan
      color7 = "#b8c0e0";   # White

      # Bright colors
      color8 = "#5b6078";
      color9 = "#ed8796";
      color10 = "#a6da95";
      color11 = "#eed49f";
      color12 = "#8aadf4";
      color13 = "#f5bde6";
      color14 = "#8bd5ca";
      color15 = "#a5adcb";
    };
  };
}
