# modules/common/bootloader.nix
# Boot loader configuration (systemd-boot for UEFI systems)
{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # Keep only last 10 generations to save /boot space
      systemd-boot.configurationLimit = 10;
    };

    # Use latest kernel for best hardware support
    kernelPackages = pkgs.linuxPackages_latest;

    # Filesystem support for external drives
    supportedFilesystems = [ "ntfs" "exfat" "btrfs" ];
  };
}
