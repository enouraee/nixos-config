# modules/common/hardware.nix
# Common hardware support (graphics, firmware, external drives)
{ pkgs, ... }:
{
  hardware = {
    # Enable GPU acceleration
    graphics = {
      enable = true;
      # Intel GPU support (common for laptops)
      extraPackages = with pkgs; [
        intel-media-driver
        (intel-vaapi-driver.override { enableHybridCodec = true; })
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };

    # Enable firmware for various hardware (WiFi, Bluetooth, etc.)
    enableRedistributableFirmware = true;

    # Bluetooth support
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # Additional hardware packages
  environment.systemPackages = with pkgs; [
    usbutils       # lsusb
    pciutils       # lspci
    lshw           # Hardware info
    smartmontools  # Disk health
  ];
}
