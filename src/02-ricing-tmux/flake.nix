{
  description = "Standalone Home Manager configuration for cowsay, Neovim, and tmux on Linux and macOS";

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

            # reference - https://mynixos.com/home-manager/options/programs.tmux
            programs.tmux = {
              enable = true;
              terminal = "screen-256color";
              mouse = true;
              keyMode = "vi";
              customPaneNavigationAndResize = true;
              baseIndex = 1;
              historyLimit = 10000;
              escapeTime = 10;
              # Also works on hosts without /run/user or XDG_RUNTIME_DIR.
              secureSocket = false;

              extraConfig = ''
                set -g renumber-windows on

                # Keep the current directory when opening windows and splits.
                bind c new-window -c "#{pane_current_path}"
                bind | split-window -h -c "#{pane_current_path}"
                bind - split-window -v -c "#{pane_current_path}"

                set -g status-style 'bg=colour235,fg=colour250'
                set -g status-left '#[fg=colour81,bold] #S #[default]'
                set -g status-right '%H:%M %d-%b'
                setw -g window-status-current-style 'fg=colour81,bold'
              '';
            };
          })
        ];
      };
    };
}
