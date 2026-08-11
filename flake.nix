{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # nixpkgs.follows intentionally omitted for quickshell and noctalia-shell:
    # following our nixpkgs changes their derivation hash and breaks cache
    # hits against noctalia.cachix.org, forcing a local compile every rebuild.
    quickshell.url = "github:outfoxxed/quickshell";
    noctalia-shell.url = "github:noctalia-dev/noctalia-shell";
    claude-code-nix.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, quickshell, noctalia-shell, claude-code-nix, ... }@inputs:
  let
    system = "x86_64-linux";
    overlays = [
      # inputs.neovim-nightly-overlay.overlays.default
      # nixpkgs' packaged hyprland can drift out of sync with the glaze/
      # hyprutils/etc. versions its CMakeLists expects (e.g. nixpkgs' glaze
      # not being found, falling back to a network FetchContent that fails
      # in the sandboxed build). Hyprland's own overlays build it and its
      # hypr* deps (including hyprland-guiutils, which nixpkgs doesn't
      # package at all) from its own in-repo Nix packaging instead, which
      # stays in sync with upstream. `default` alone omits the dependency
      # overlays, so use the same combo Hyprland's own flake uses for its
      # `packages.hyprland` output.
      hyprland.overlays.hyprland-packages
      hyprland.overlays.hyprland-extras
      quickshell.overlays.default
      claude-code-nix.overlays.default
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
        ./hosts/my-pc/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.pravin = import ./home;
            backupFileExtension = "backup";
            extraSpecialArgs = {
                flakePath = "/home/pravin/nixos-dotfiles";
                inherit inputs;
            };
          };
        }
      ];
    };
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
          nodejs_24
          bubblewrap
          python3
          uv
      ];
      shellHook = ''
        export NPM_CONFIG_PREFIX="$HOME/.npm-global"
        export npm_config_prefix="$HOME/.npm-global"
        export PATH="$HOME/.npm-global/bin:$PATH"
        mkdir -p "$HOME/.npm-global"
        echo "python: $(python --version)"
      '';
    };
  };
}
