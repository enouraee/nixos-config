{
  description = "Minimal NixOS configuration with Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix - system-wide theming (Base16)
    stylix.url = "github:danth/stylix";
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs:
    let
      # ====== CONFIGURATION ======
      # IMPORTANT: Change this to your desired username before installing!
      username = "initdaddy";  # <-- SET YOUR USERNAME HERE
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Common modules for all hosts (includes stylix theming)
      commonModules = [
        stylix.nixosModules.stylix
        ./modules/theme/stylix-default.nix
      ];
    in
    {
      # NixOS configurations - expose hosts here
      nixosConfigurations = {
        # ExpertBook host (laptop)
        expertbook = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = commonModules ++ [
            ./hosts/expertbook
          ];
          specialArgs = {
            host = "expertbook";
            inherit self inputs home-manager username;
          };
        };

        # ====== ADD NEW HOSTS HERE ======
        # Example:
        # desktop = nixpkgs.lib.nixosSystem {
        #   inherit system;
        #   modules = commonModules ++ [ ./hosts/desktop ];
        #   specialArgs = {
        #     host = "desktop";
        #     inherit self inputs username;
        #   };
        # };
      };
    };
}
