{
  description = "Home Manager tmux configuration for Linux and macOS, with Option+Space input switching on macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      # Use the Home Manager CLI from the same locked input as the configuration.
      packages = nixpkgs.lib.genAttrs systems (system: {
        default = home-manager.packages.${system}.home-manager;
      });

      # With Nix and flakes enabled, run from this directory as your regular user:
      # nix run . -- switch --flake .#default --impure
      # --impure allows detecting the current system, USER, and HOME.
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};

        modules = [
          ({ pkgs, ... }: {
            imports = [ ./home/tmux ./os/darwin ];

            home = {
              username = builtins.getEnv "USER";
              homeDirectory = builtins.getEnv "HOME";
              packages = [
                pkgs.cowsay
                pkgs.neovim
              ];
              # Keep this value when updating inputs on an existing installation.
              stateVersion = "26.05";
            };

            programs.home-manager.enable = true;
          })
        ];
      };
    };
}
