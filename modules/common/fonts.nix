# modules/common/fonts.nix
# System fonts
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    # System fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    # Programming fonts with Nerd Font icons
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
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
