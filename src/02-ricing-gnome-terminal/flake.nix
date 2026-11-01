{
  description = "Standalone Home Manager configuration for cowsay, Neovim, and GNOME Terminal with Iosevka Nerd Font on Linux";

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
            fonts.fontconfig.enable = true;

            programs.gnome-terminal = {
              enable = true;
              themeVariant = "dark";
              profile."7a6df33c-9afd-45e3-9d3b-1693246b72e8" = {
                default = true;
                visibleName = "Ricing";
                font = "Iosevka Nerd Font Mono 12";
                loginShell = true;
                audibleBell = false;

                colors = {
                  foregroundColor = "#e6edf3";
                  backgroundColor = "#161b22";
                  boldColor = "#ffffff";
                  cursor = {
                    foreground = "#161b22";
                    background = "#79c0ff";
                  };
                  highlight = {
                    foreground = "#ffffff";
                    background = "#264f78";
                  };
                  palette = [
                    # Keep ANSI black text readable against the dark background.
                    "#8b949e"
                    "#ff7b72"
                    "#7ee787"
                    "#e3b341"
                    "#79c0ff"
                    "#d2a8ff"
                    "#76e3ea"
                    "#e6edf3"
                    "#9da7b3"
                    "#ffa198"
                    "#aff5b4"
                    "#f8e3a1"
                    "#a5d6ff"
                    "#e2c5ff"
                    "#b3f0ff"
                    "#ffffff"
                  ];
                };
              };
            };
          })
        ];
      };
    };
}
