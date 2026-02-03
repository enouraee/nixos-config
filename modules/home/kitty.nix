# modules/home/kitty.nix
# Kitty terminal emulator
# Note: Colors, fonts, and opacity are managed by Stylix
{ ... }:
{
  programs.kitty = {
    enable = true;

    settings = {
      # Cursor behavior (not colors - stylix handles those)
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

      # Font settings managed by Stylix, only set style preferences here
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
    };
  };
}
