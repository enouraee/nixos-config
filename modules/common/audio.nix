# modules/common/audio.nix
# Modern PipeWire audio stack
{ pkgs, ... }:
{
  # Disable PulseAudio (we use PipeWire instead)
  services.pulseaudio.enable = false;

  # PipeWire - modern audio/video routing
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;  # For 32-bit apps/games
    pulse.enable = true;       # PulseAudio compatibility
    wireplumber.enable = true; # Session manager
  };

  # Note: rtkit is enabled in security.nix

  # Keep ALSA state across reboots
  hardware.alsa.enablePersistence = true;

  # Audio control tools
  environment.systemPackages = with pkgs; [
    pulseaudioFull  # For pactl and other tools
    pavucontrol     # GUI volume control
  ];
}
