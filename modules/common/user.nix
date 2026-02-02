# modules/common/user.nix
# User creation and Home Manager integration
{ pkgs, inputs, username, host, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Home Manager configuration
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs username host; };

    users.${username} = {
      imports = [ ./../home ];

      home.username = "${username}";
      home.homeDirectory = "/home/${username}";
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
    };

    # Backup conflicting files instead of failing
    backupFileExtension = "hm-backup";
  };

  # Create the user
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "wheel"          # Sudo access
      "networkmanager" # Network management
      "video"          # Brightness control
      "audio"          # Audio devices
      "docker"         # Docker (if enabled)
      "libvirtd"       # VMs (if enabled)
    ];
    shell = pkgs.zsh;  # Set zsh as default shell
  };

  # Allow user to run nix commands
  nix.settings.allowed-users = [ "${username}" ];

  # Enable zsh system-wide (required for it to be a valid login shell)
  programs.zsh.enable = true;
}
