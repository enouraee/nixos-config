# modules/home/xdg.nix
# XDG directories and default applications
{ config, ... }:
{
  xdg = {
    enable = true;

    # Standard directories
    userDirs = {
      enable = true;
      createDirectories = true;

      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
    };

    # Default applications (customize as needed)
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Web
        "text/html" = [ "google-chrome.desktop" ];
        "x-scheme-handler/http" = [ "google-chrome.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome.desktop" ];

        # Images
        "image/png" = [ "imv.desktop" ];
        "image/jpeg" = [ "imv.desktop" ];
        "image/gif" = [ "imv.desktop" ];

        # Video
        "video/mp4" = [ "mpv.desktop" ];
        "video/mkv" = [ "mpv.desktop" ];
        "video/webm" = [ "mpv.desktop" ];

        # Audio
        "audio/mpeg" = [ "mpv.desktop" ];
        "audio/flac" = [ "mpv.desktop" ];

        # Text
        "text/plain" = [ "code.desktop" ];

        # File manager
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      };
    };
  };

  # Create Screenshots directory
  home.file."Pictures/Screenshots/.keep".text = "";
}
