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
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };
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
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nodejs_24
	bubblewrap
      ];
      shellHook = ''
        export NPM_CONFIG_PREFIX = "$HOME/.npm-global"
	export npm_config_prefix = "$HOME/.npm-global"
	export PATH = "$HOME/.npm-global/bin:$PATH"
	mkdir -p "$HOME/.npm-global"
      '';
    };
  };
}
