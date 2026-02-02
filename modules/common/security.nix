# modules/common/security.nix
# Security settings (sudo, PAM, polkit)
{ pkgs, ... }:
{
  security = {
    # Real-time kit for audio
    rtkit.enable = true;

    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;  # Require password for sudo
    };

    # PAM services for screen lockers
    pam.services = {
      swaylock = { };
      hyprlock = { };
    };

    # Polkit for privilege escalation dialogs
    polkit.enable = true;
  };

  # Polkit authentication agent
  environment.systemPackages = with pkgs; [
    polkit_gnome
  ];
}
