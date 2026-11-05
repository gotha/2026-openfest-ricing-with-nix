{
  description = "Shared tmux configuration for macOS, Debian, and NixOS";

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
    system-manager = {
      url = "github:numtide/system-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      system-manager,
      ...
    }:
    let
      system = builtins.currentSystem;
      isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;
      # Rebuilds may run under sudo; configure the invoking account, not root.
      sudoUser = builtins.getEnv "SUDO_USER";
      username = if sudoUser != "" then sudoUser else builtins.getEnv "USER";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      homeManager = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username} = import ./home;
        };
      };
    in
    {
      # Select the rebuild tool for the current operating system.
      packages = nixpkgs.lib.genAttrs systems (
        system:
        if nixpkgs.lib.hasSuffix "-darwin" system then
          {
            default = nix-darwin.packages.${system}.darwin-rebuild;
          }
        else
          {
            default = system-manager.packages.${system}.default;
            system-manager = system-manager.packages.${system}.default;
            nixos-rebuild = nixpkgs.legacyPackages.${system}.nixos-rebuild;
          }
      );

      # macOS, including Home Manager for the invoking user:
      # sudo nix run . -- switch --flake .#default --impure
      darwinConfigurations = nixpkgs.lib.optionalAttrs isDarwin {
        default = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit username; };
          modules = [
            ./os/darwin
            home-manager.darwinModules.home-manager
            homeManager
            { nixpkgs.hostPlatform = system; }
          ];
        };
      };

      # Debian, including Home Manager for the existing account:
      # nix run . -- switch --flake .#default --sudo --nix-option pure-eval false
      systemConfigs = nixpkgs.lib.optionalAttrs (!isDarwin) {
        default = system-manager.lib.makeSystemConfig {
          specialArgs = { inherit username; };
          modules = [
            ./os/debian
            home-manager.nixosModules.home-manager
            homeManager
            { nixpkgs.hostPlatform = system; }
          ];
        };
      };

      # NixOS, extending this machine's /etc/nixos/configuration.nix:
      # sudo nix run .#nixos-rebuild -- switch --flake .#default --impure
      nixosConfigurations = nixpkgs.lib.optionalAttrs (!isDarwin) {
        default = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit username; };
          modules = [
            ./os/nixos
            home-manager.nixosModules.home-manager
            homeManager
            { nixpkgs.hostPlatform = system; }
          ];
        };
      };
    };
}
