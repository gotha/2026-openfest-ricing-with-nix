{
  description = "Standalone Home Manager configuration for cowsay, Neovim, and Alacritty with Iosevka Nerd Font on Linux and macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, nixgl, ... }:
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
          ({ config, lib, pkgs, ... }: {
            home = {
              username = builtins.getEnv "USER";
              homeDirectory = builtins.getEnv "HOME";
              packages = [
                pkgs.cowsay
                pkgs.neovim
                pkgs.nerd-fonts.iosevka
              ];
              # Keep this value when updating inputs on an existing installation.
              stateVersion = "26.05";
            };

            programs.home-manager.enable = true;

            # Let Linux applications discover fonts installed in the user profile.
            fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;

            # Supply Mesa drivers for Nix GUI applications on Debian and other distros.
            targets.genericLinux = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
              enable = true;
              nixGL = {
                packages = nixgl.packages;
                defaultWrapper = "mesa";
              };
            };

            programs.alacritty = {
              enable = true;
              package = config.lib.nixGL.wrap pkgs.alacritty;
              settings.font = {
                normal.family = "Iosevka Nerd Font Mono";
                size = 12.0;
              };
            };
          })
        ];
      };
    };
}
