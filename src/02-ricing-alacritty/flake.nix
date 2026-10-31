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
              settings = {
                font = {
                  normal.family = "Iosevka Nerd Font Mono";
                  size = 12.0;
                };

                window = {
                  padding = { x = 12; y = 12; };
                  opacity = 1.0;
                  decorations_theme_variant = "Dark";
                };

                colors = {
                  primary = {
                    background = "#161b22";
                    foreground = "#e6edf3";
                    dim_foreground = "#9da7b3";
                    bright_foreground = "#ffffff";
                  };
                  cursor = {
                    text = "#161b22";
                    cursor = "#79c0ff";
                  };
                  selection = {
                    text = "#ffffff";
                    background = "#264f78";
                  };
                  normal = {
                    # Keep ANSI black text readable against the dark background.
                    black = "#8b949e";
                    red = "#ff7b72";
                    green = "#7ee787";
                    yellow = "#e3b341";
                    blue = "#79c0ff";
                    magenta = "#d2a8ff";
                    cyan = "#76e3ea";
                    white = "#e6edf3";
                  };
                  bright = {
                    black = "#9da7b3";
                    red = "#ffa198";
                    green = "#aff5b4";
                    yellow = "#f8e3a1";
                    blue = "#a5d6ff";
                    magenta = "#e2c5ff";
                    cyan = "#b3f0ff";
                    white = "#ffffff";
                  };
                };
              };
            };
          })
        ];
      };
    };
}
