# modules/home/packages.nix
# User packages (add your apps here)
{ pkgs, lib, ... }:

let
  isX86 = pkgs.stdenv.hostPlatform.isx86_64;
in
{
  home.packages = with pkgs;
    [
      # ====== TERMINALS & SHELLS ======
      tmux
      neofetch

      # ====== DEVELOPMENT ======
      git
      vim
      vscode
      go
      python3
      python3Packages.pip

      # ====== NETWORKING / VPN ======
      wireguard-tools
      openvpn

      # ====== MEDIA ======
      vlc
      mpv
      imv           # Image viewer

      # ====== COMMUNICATION ======
      telegram-desktop

      # ====== UTILITIES ======
      bitwarden-desktop
      thunderbird
      file-roller   # Archive manager

      # ====== HYPRLAND UTILITIES ======
      waybar        # Status bar
      wofi          # App launcher
      mako          # Notifications
      swaylock      # Screen locker
      wlogout       # Logout menu
      brightnessctl # Brightness control
      playerctl     # Media control
      udiskie       # Auto-mount USB

      # ====== FILE MANAGEMENT ======
      gnome-calculator
      nautilus      # File manager (or use `nemo`)
    ]
    # ====== x86-only / PROPRIETARY ======
    ++ lib.optionals isX86 [
      google-chrome
      spotify
      discord
    ];
}
