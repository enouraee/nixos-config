{
  description = "Minimal NixOS configuration with Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # ====== CONFIGURATION ======
      # IMPORTANT: Change this to your desired username before installing!
      username = "initdaddy";  # <-- SET YOUR USERNAME HERE
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # NixOS configurations - expose hosts here
      nixosConfigurations = {
        # ExpertBook host (laptop)
        expertbook = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
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
        #   modules = [ ./hosts/desktop ];
        #   specialArgs = {
        #     host = "desktop";
        #     inherit self inputs username;
        #   };
        # };
      };
    };
}
