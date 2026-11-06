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
          debian = self.systemConfigs.${system}.config;
          debianHome = debian.home-manager.users.${username};
        in
        {
          home = home.activationPackage;
          helpers = self.packages.${system}.nixarchy;
          session-startup = pkgs.runCommand "nixarchy-session-startup" { } ''
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME/.nix-profile/bin" "$HOME/.nix-profile/etc/profile.d"
            cat > "$HOME/.nix-profile/bin/uwsm" <<'EOF'
            #!${pkgs.runtimeShell}
            set -eu
            test "$XCURSOR_THEME" = Bibata-Modern-Ice
            test "$XCURSOR_PATH" = "$EXPECTED_CURSOR_PATH"
            test "$XDG_CURRENT_DESKTOP" = Hyprland
            test "$XDG_SESSION_TYPE" = wayland
            for directory in /usr/local/share /usr/share "$HOME/.nix-profile/share" "$EXPECTED_DATA_DIR"; do
              case ":$XDG_DATA_DIRS:" in
                *":$directory:"*) ;;
                *) echo "Missing session data directory: $directory" >&2; exit 1 ;;
              esac
            done
            test "$*" = 'start -F -D Hyprland -- start-hyprland'
            touch "$SESSION_STARTED"
            EOF
            chmod +x "$HOME/.nix-profile/bin/uwsm"

            for profile in ${home.config.home.sessionVariablesPackage} ${debianHome.home.sessionVariablesPackage}; do
              ln -sf "$profile/etc/profile.d/hm-session-vars.sh" \
                "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
              for cursor in unset /existing/icons; do
                rm -f session-started
                cursorEnv=()
                cursorSuffix=""
                if test "$cursor" != unset; then
                  cursorEnv=("XCURSOR_PATH=$cursor")
                  cursorSuffix=":$cursor"
                fi
                cursorPrefix=$(sed -n 's/^export XCURSOR_PATH="\([^$]*\)\$.*/\1/p' \
                  "$profile/etc/profile.d/hm-session-vars.sh")
                test -n "$cursorPrefix"
                for data in /usr/share /inherited/share; do
                  rm -f session-started
                  dataEnv=()
                  if test "$data" != /usr/share; then
                    dataEnv=("XDG_DATA_DIRS=$data")
                  fi
                  env -i HOME="$HOME" USER=nixarchy-test PATH="$PATH" \
                    SESSION_STARTED="$PWD/session-started" EXPECTED_DATA_DIR="$data" \
                    EXPECTED_CURSOR_PATH="$cursorPrefix$cursorSuffix" \
                    "''${cursorEnv[@]}" "''${dataEnv[@]}" \
                    ${self.packages.${system}.nixarchy}/bin/nixarchy-session
                  test -f session-started
                done
              done
            done
            touch "$out"
          '';
          debian-session =
            pkgs.runCommand "nixarchy-debian-session"
              {
                nativeBuildInputs = [
                  pkgs.dbus
                  pkgs.dconf
                ];
              }
              ''
                for unit in wayland-session-bindpid@.service wayland-wm@.service wayland-wm-env@.service wayland-session@.target; do
                  test -r ${debianHome.xdg.dataFile."systemd/user".source}/"$unit"
                done

                export HOME="$TMPDIR/home"
                export XDG_CONFIG_HOME="$HOME/.config"
                mkdir -p "$XDG_CONFIG_HOME"
                config=${debian.environment.etc."dbus-1/session.conf".source}
                # Debian's standard configuration also includes the legacy /etc file.
                sed "s|/etc/dbus-1/session.conf|$config|" \
                  ${pkgs.dbus}/share/dbus-1/session.conf > debian-session.conf
                for config in "$config" "$PWD/debian-session.conf"; do
                  dbus-daemon --config-file="$config" --fork --print-address=3 --print-pid=4 \
                    3>bus-address 4>bus-pid
                  trap 'kill "$(cat bus-pid)"' EXIT
                  export DBUS_SESSION_BUS_ADDRESS="$(cat bus-address)"
                  dconf write /nixarchy-check/value "'ready'"
                  test "$(dconf read /nixarchy-check/value)" = "'ready'"
                  kill "$(cat bus-pid)"
                  trap - EXIT
                done
                touch "$out"
              '';
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
