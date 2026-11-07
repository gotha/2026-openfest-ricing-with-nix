{
  description = "Hannah Montana Plasma desktop for NixOS and Debian with system-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
      plasma-manager,
      system-manager,
      nix-system-graphics,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      requestedUser = builtins.getEnv "HANNAH_MONTANA_USER";
      sudoUser = builtins.getEnv "SUDO_USER";
      username =
        if requestedUser != "" then
          requestedUser
        else if sudoUser != "" then
          sudoUser
        else
          builtins.getEnv "USER";
      requestedHome = builtins.getEnv "HANNAH_MONTANA_HOME";
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
      homeManagerModules.default = {
        imports = [
          plasma-manager.homeModules.plasma-manager
          ./home
        ];
      };
      nixosModules.default = { username, ... }: {
        imports = [
          home-manager.nixosModules.home-manager
          ./os/common.nix
          ./os/nixos
        ];
        home-manager.users.${username}.imports = [ self.homeManagerModules.default ];
      };
      systemModules.default = { username, ... }: {
        imports = [
          home-manager.nixosModules.home-manager
          nix-system-graphics.systemModules.default
          ./os/common.nix
          ./os/system-manager
        ];
        home-manager.users.${username}.imports = [ self.homeManagerModules.default ];
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
          theme = pkgs.callPackage ./packages/theme.nix { };
          sddm-theme = pkgs.callPackage ./packages/sddm { };
        }
      );
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
      systemConfigs =
        forAllSystems mkSystem
        // lib.optionalAttrs (lib.elem builtins.currentSystem systems) {
          default = mkSystem builtins.currentSystem;
        };
      nixosConfigurations =
        forAllSystems mkNixOS
        // lib.optionalAttrs (lib.elem builtins.currentSystem systems) {
          default = mkNixOS builtins.currentSystem;
        };

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          home = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = {
              backend = "nixos";
              extras = true;
            };
            modules = [
              self.homeManagerModules.default
              {
                home.username = "hannah-test";
                home.homeDirectory = "/home/hannah-test";
              }
            ];
          };
          nixos = nixpkgs.lib.nixosSystem {
            specialArgs.username = "hannah-test";
            modules = [
              self.nixosModules.default
              {
                nixpkgs.hostPlatform = system;
                boot.loader.grub.enable = false;
                fileSystems."/" = {
                  device = "/dev/disk/by-label/nixos";
                  fsType = "ext4";
                };
                system.stateVersion = "26.05";
              }
            ];
          };
        in
        {
          home = home.activationPackage;
          nixos = nixos.config.system.build.toplevel;
          theme = pkgs.runCommand "hannah-montana-theme-check" { nativeBuildInputs = [ pkgs.python3 ]; } ''
            python3 ${./tests/theme.py} ${self.packages.${system}.theme} ${self.packages.${system}.sddm-theme}
            touch "$out"
          '';
          login-theme =
            pkgs.runCommand "hannah-montana-login-theme-check"
              {
                nativeBuildInputs = [ pkgs.kdePackages.sddm ];
              }
              ''
                export HOME="$TMPDIR/home" XDG_RUNTIME_DIR="$TMPDIR/runtime"
                mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
                chmod 700 "$XDG_RUNTIME_DIR"
                export QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_QUICK_CONTROLS_STYLE=Basic
                export FONTCONFIG_FILE=${pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; }}
                greeter=${pkgs.kdePackages.sddm}/bin/sddm-greeter-qt6
                if ! test -x "$greeter"; then greeter=${pkgs.kdePackages.sddm}/bin/sddm-greeter; fi
                status=0
                timeout 5s "$greeter" --test-mode --theme ${
                  self.packages.${system}.sddm-theme
                }/share/sddm/themes/hannah-montana >greeter.log 2>&1 || status=$?
                cat greeter.log
                test "$status" -eq 124
                if grep -Ei 'ReferenceError|TypeError|failed to load|is not installed|is not a type|Cannot assign' greeter.log; then exit 1; fi
                touch "$out"
              '';
          system-manager-etc = pkgs.runCommand "hannah-montana-system-manager-etc" { } ''
            find -L ${self.systemConfigs.${system}.config.build.etc.staticEnv} -type l -print > dangling-links
            if test -s dangling-links; then
              cat dangling-links
              exit 1
            fi
            touch "$out"
          '';
          session-env =
            pkgs.runCommand "hannah-montana-session-env" { nativeBuildInputs = [ pkgs.python3 ]; }
              ''
                python3 ${./tests/session.py} ${./home/plasma/session-env.sh}
                touch "$out"
              '';
        }
      );
    };
}
