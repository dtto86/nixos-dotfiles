{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  in {
    nixosConfigurations.my-pc = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        flakePath = "/home/pravin/nixos-dotfiles";
      };
      modules = [
        {
          nixpkgs.config.allowUnfree = true;
        }
        {
            nixpkgs.overlays = overlays;
        }
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.pravin = import ./home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = {
                flakePath = "/home/pravin/nixos-dotfiles";
            };
          };
        }
      ];
    };
  };
}
