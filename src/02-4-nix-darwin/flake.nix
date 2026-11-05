{
  description = "Shared tmux configuration with standalone Home Manager on Linux and nix-darwin on macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, nix-darwin, ... }:
    let
      system = builtins.currentSystem;
      isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;
      # macOS rebuilds run under sudo; configure the invoking account, not root.
      sudoUser = builtins.getEnv "SUDO_USER";
      username = if sudoUser != "" then sudoUser else builtins.getEnv "USER";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      # Select the rebuild tool for the current operating system.
      packages = nixpkgs.lib.genAttrs systems (system: {
        default =
          if nixpkgs.lib.hasSuffix "-darwin" system then
            nix-darwin.packages.${system}.darwin-rebuild
          else
            home-manager.packages.${system}.home-manager;
      });

      # Linux, as your regular user:
      # nix run . -- switch --flake .#default --impure
      homeConfigurations = nixpkgs.lib.optionalAttrs (!isDarwin) {
        default = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home
            {
              home.username = username;
              home.homeDirectory = builtins.getEnv "HOME";
            }
          ];
        };
      };

      # macOS, including Home Manager for the invoking user:
      # sudo nix run . -- switch --flake .#default --impure
      darwinConfigurations = nixpkgs.lib.optionalAttrs isDarwin {
        default = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit username; };
          modules = [
            ./os/darwin
            home-manager.darwinModules.home-manager
            {
              nixpkgs.hostPlatform = system;
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./home;
              };
            }
          ];
        };
      };
    };
}
