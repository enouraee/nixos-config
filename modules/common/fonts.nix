# modules/common/fonts.nix
# System fonts
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    # System fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    # Programming fonts with Nerd Font icons
    (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    jetbrains-mono

    # UI icons (for waybar, etc.)
    font-awesome
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
