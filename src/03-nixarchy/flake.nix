{
  description = "Nixarchy: an Omarchy-inspired desktop for NixOS and Debian";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      system-manager,
      nix-system-graphics,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      currentSystem = builtins.currentSystem;
      requestedUser = builtins.getEnv "NIXARCHY_USER";
      sudoUser = builtins.getEnv "SUDO_USER";
      username =
        if requestedUser != "" then
          requestedUser
        else if sudoUser != "" then
          sudoUser
        else
          builtins.getEnv "USER";
      requestedHome = builtins.getEnv "NIXARCHY_HOME";
      homeDirectory = if requestedHome != "" then requestedHome else "/home/${username}";
      mkSystem =
        system:
        system-manager.lib.makeSystemConfig {
          specialArgs = { inherit username homeDirectory; };
          modules = [
            self.systemModules.default
            { nixpkgs.hostPlatform = system; }
          ];
        };
      mkNixOS =
        system:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit username; };
          modules = [
            self.nixosModules.default
            ./os/nixos/host.nix
            { nixpkgs.hostPlatform = system; }
          ];
        };
    in
    {
      homeManagerModules.default = import ./home;
      nixosModules.default = {
        imports = [
          home-manager.nixosModules.home-manager
          ./os/common.nix
          ./os/nixos
        ];
      };
      systemModules.default = {
        imports = [
          home-manager.nixosModules.home-manager
          nix-system-graphics.systemModules.default
          ./os/common.nix
          ./os/system-manager
        ];
      };

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = system-manager.packages.${system}.default;
          system-manager = system-manager.packages.${system}.default;
          nixos-rebuild = pkgs.nixos-rebuild;
          nixarchy = pkgs.callPackage ./packages { };
        }
      );
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      systemConfigs =
        forAllSystems mkSystem
        // lib.optionalAttrs (lib.elem currentSystem systems) {
          default = mkSystem currentSystem;
        };
      nixosConfigurations =
        forAllSystems mkNixOS
        // lib.optionalAttrs (lib.elem currentSystem systems) {
          default = mkNixOS currentSystem;
        };

      # Build these without reading a real host's hardware configuration.
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          home = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              backend = "nixos";
              bluetooth = false;
            };
            modules = [
              ./home
              {
                home.username = "nixarchy-test";
                home.homeDirectory = "/home/nixarchy-test";
              }
            ];
          };
        in
        {
          home = home.activationPackage;
          helpers = self.packages.${system}.nixarchy;
          system-manager-etc =
            pkgs.runCommand "nixarchy-system-manager-etc" { nativeBuildInputs = [ pkgs.findutils ]; }
              ''
                find -L ${self.systemConfigs.${system}.config.build.etc.staticEnv} \
                  -type l -print > dangling-links
                if test -s dangling-links; then
                  echo 'System-manager cannot activate these dangling symlinks:'
                  cat dangling-links
                  exit 1
                fi
                touch "$out"
              '';
          helper-behavior =
            pkgs.runCommand "nixarchy-helper-behavior"
              {
                nativeBuildInputs = [
                  pkgs.bash
                  pkgs.python3
                  pkgs.util-linux
                ];
              }
              ''
                python3 ${./tests/helpers.py} ${./packages/nixarchy.sh}
                touch "$out"
              '';
          desktop-config =
            pkgs.runCommand "nixarchy-desktop-config"
              {
                nativeBuildInputs = [
                  pkgs.hyprland
                  pkgs.foot
                  home.config.programs.neovim.finalPackage
                ];
              }
              ''
                export HOME="$TMPDIR/home"
                export XDG_RUNTIME_DIR="$TMPDIR/runtime"
                mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
                chmod 700 "$XDG_RUNTIME_DIR"
                echo 'Checking Hyprland configuration'
                timeout 45s Hyprland --verify-config -c ${home.config.xdg.configFile."hypr/hyprland.lua".source}
                echo 'Checking Foot configuration'
                timeout 45s foot --check-config --config=${home.config.xdg.configFile."foot/foot.ini".source}
                echo 'Checking Neovim configuration'
                timeout 45s nvim --headless '+qall'
                touch "$out"
              '';
        }
      );
    };
}
