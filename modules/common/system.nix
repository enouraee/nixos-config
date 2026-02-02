# modules/common/system.nix
# Nix settings, timezone, locale
{ pkgs, ... }:
{
  # Nix package manager settings
  nix = {
    settings = {
      # Optimize store automatically
      auto-optimise-store = true;

      # Enable flakes and new CLI
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Binary caches for faster builds
      substituters = [
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };

  # Timezone - Asia/Tehran
  time.timeZone = "Asia/Tehran";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Allow unfree packages (Chrome, Spotify, etc.)
  nixpkgs.config.allowUnfree = true;

  # Base system packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    htop
    unzip
    file
  ];

  # NixOS version (update when upgrading)
  system.stateVersion = "24.11";
}
