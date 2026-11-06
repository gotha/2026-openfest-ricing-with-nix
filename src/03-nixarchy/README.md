# Nixarchy

An Omarchy-inspired Hyprland desktop, following the initial modular setup in
[`PLAN-omarchy.md`](../../PLAN-omarchy.md). One Home Manager configuration supplies
the desktop and applications to both NixOS and system-manager on Debian.

The default theme is Tokyo Night, with Iosevka Nerd Font, a matching mountain
wallpaper, dark GTK applications, Yaru icons, and a Bibata cursor. The wallpaper
is included as SVG source and rendered to PNG during the build.

## What it installs

| Area | Software |
| --- | --- |
| Desktop | Hyprland, UWSM, Waybar, Walker, Elephant, Mako, Swaybg, Hyprlock, Hypridle, SwayOSD, GNOME Polkit agent |
| Terminal | Foot, Bash completion, Starship, tmux with pinned plugins |
| Development | Neovim with Tokyo Night, Telescope and Gitsigns; Git, Lazygit, ripgrep, fd, fzf, bat, eza, zoxide |
| Applications | Chromium, Nautilus, btop, imv, mpv, Evince |
| Capture | wl-clipboard, Cliphist, grim, slurp, Satty, wf-recorder |
| Controls | PipeWire/WirePlumber tools, pavucontrol, pamixer, playerctl, brightnessctl, NetworkManager applet, Blueman |
| Appearance | Iosevka and JetBrains Mono Nerd Fonts, Noto text/emoji, Font Awesome, adw-gtk3, Yaru, Bibata |
| Helpers | `nixarchy`, `nixarchy-session`, jq, gum, libnotify, xdg-utils |

UWSM owns the graphical session. Home Manager starts the desktop services once
and stops them with that session. Cliphist owns clipboard history; Elephant is
built with only application, runner, file, and calculator providers.

The pinned Waybar 0.15 package includes the upstream Lua dispatch fix from
[Waybar PR #5013](https://github.com/Alexays/Waybar/pull/5013), so clicking workspace
buttons works with Hyprland 0.55's Lua configuration.

The Quickshell port, extra office/media applications, OCR, and other items listed
under "Later additions" in the plan remain optional future work.

When adopting existing dotfiles, Home Manager saves unmanaged files with the
suffix `.before-nixarchy`. It refuses to overwrite an existing backup with the
same name. Review those backups when moving any personal settings into Nix.

## Apply on NixOS

From the repository root:

```sh
cd src/03-nixarchy
sudo nix run .#nixos-rebuild -- switch --flake .#default --impure
```

This extends `/etc/nixos/configuration.nix`, including its hardware import,
bootloader, filesystems, accounts, and `system.stateVersion`. It uses the locked
Nixpkgs 26.05 release. The existing host file must not import this flake back into
itself. For a different location:

```sh
sudo env NIXOS_CONFIG=/absolute/path/to/configuration.nix \
  nix run .#nixos-rebuild -- switch --flake .#default --impure
```

Log out and choose **Hyprland (UWSM)** at the login screen. Existing GDM, SDDM,
LightDM, and Ly configurations are retained. A minimal host gets greetd with
tuigreet. Hosts with a custom login manager should set `services.greetd.enable =
false` in their host configuration and start `nixarchy-session` from a local TTY
or add it to that manager.

NixOS configures graphics, PipeWire, RTKit, NetworkManager, portals, Polkit,
Hyprlock PAM authentication, GNOME Keyring, GVfs, UDisks2, and backlight rules.
The host continues to supply hardware-specific drivers and locale settings.

## Apply on Debian with system-manager

Use a Debian desktop with Nix and working graphics. Debian retains its kernel,
login manager, accounts, networking, audio daemons, and system D-Bus services.
Install any missing host integration first:

```sh
sudo apt install dbus-user-session libpam-systemd polkitd \
  pipewire pipewire-pulse wireplumber network-manager \
  gnome-keyring libpam-gnome-keyring gvfs gvfs-backends udisks2
```

Use Debian's normal service configuration to ensure NetworkManager and the
PipeWire/WirePlumber user services are running. On an existing desktop they may
already be enabled. Changing an SSH server's active network configuration should
be done from its local console.

Run the switch as your regular desktop user:

```sh
cd src/03-nixarchy
nix run . -- switch --flake .#default --sudo --nix-option pure-eval false
```

System-manager activates Home Manager and adds a **Nixarchy** entry to
`/usr/share/wayland-sessions`. Home Manager installs the desktop packages in its
own user profile. This avoids system-manager traversing icon-theme packages
under `/etc/profiles/per-user`, where dangling icon symlinks can stop activation.
It also registers UWSM's user units through Home Manager and provides the session
bus configuration needed for activation before anyone has logged in.
The session launcher keeps `/usr/local/share` and `/usr/share` in `XDG_DATA_DIRS`
so Debian's services can find their GSettings schemas and other desktop data.
Log out fully, then select that session.
You can also run `nixarchy-session` from a local TTY. Avoid starting it inside an
existing GNOME session or over SSH. Log out and back in after the first switch to
refresh the user profile paths.

The system-manager target uses
[`nix-system-graphics`](https://github.com/soupglasses/nix-system-graphics) to
populate `/run/opengl-driver` with the same Mesa release as the applications.
It needs no nixGL wrapper. The default targets Mesa-supported GPUs; proprietary
NVIDIA hosts need a matching `system-graphics.package` override. A VM must expose
a working graphics device; installing the desktop cannot add host GPU support.

For Hyprlock, this target installs a dedicated `/etc/pam.d/hyprlock` and the same
`unix_chkpwd` privilege wrapper used by NixOS. It supports local password accounts.
Hosts using LDAP, smart cards, or a different authentication policy should supply
their own lock-screen PAM configuration. Existing unmanaged files are not
overwritten by system-manager. If an existing Hyprlock PAM file conflicts, review
and back it up before giving system-manager ownership of that file.

Debian's PAM/D-Bus integration owns the keyring daemon. Keyring auto-unlock depends
on the chosen host login manager's GNOME Keyring PAM integration. For physical
backlight controls, Debian also needs permission rules for the backlight device;
its native `brightnessctl` package provides those rules.

## Accounts and Bluetooth

The flake reads `SUDO_USER`, falling back to `USER`. `NIXARCHY_USER` overrides both.
On Debian, the home defaults to `/home/<user>`; set `NIXARCHY_HOME` for another path:

```sh
NIXARCHY_USER=gotha NIXARCHY_HOME=/srv/gotha \
  nix run . -- switch --flake .#default --sudo --nix-option pure-eval false
```

On NixOS, Home Manager uses the account's home directory from the host
configuration. The rebuild requires an existing desktop account with a working
login method.

Bluetooth software is installed, while the applet and NixOS Bluetooth services
are enabled only when the host declares:

```nix
nixarchy.bluetooth.enable = true;
```

On Debian, put this setting in `os/system-manager/default.nix`, install Debian's
`bluez` and `blueman` packages for system integration, and enable `bluetooth.service`.

## Shortcuts and desktop commands

| Shortcut | Action |
| --- | --- |
| `Super+Return` | Foot |
| `Super+Shift+Return` | Chromium |
| `Super+Alt+Return` | Create or attach to the main tmux session |
| `Super+Space` | Walker application search |
| `Super+Alt+Space` | Desktop menu |
| `Super+E` | Nautilus |
| `Super+K` | Help generated from the actual declared bindings |
| `Super+1..9` | Switch workspace; Shift moves the current window |
| `Super+Arrow` | Focus a window; Shift swaps windows |
| `Super+F` / `Super+T` | Fullscreen / floating |
| `Super+V` | Clipboard history |
| `Print` / `Shift+Print` / `Ctrl+Print` | Region / window / full screenshot with annotation |
| `Super+Shift+R` | Start or stop region recording; the bar shows the recording state |
| `Super+Ctrl+L` | Lock |
| `Super+Shift+I` | Pause/resume automatic idle locking |
| `Super+Shift+N` | Toggle do-not-disturb |
| `Ctrl+Space` inside tmux | tmux prefix |

`nixarchy --help` lists the same actions as terminal commands. Screenshots save
under `~/Pictures/Screenshots` and recordings under `~/Videos/Recordings`, honoring
`XDG_PICTURES_DIR` and `XDG_VIDEOS_DIR` when exported. Canceled capture selections
do nothing. Recordings run in their own systemd user service and stop with SIGINT
to finish the output file. Power actions require confirmation in the desktop menu.

tmux retains the previous example's bindings and plugins. Home Manager installs
the plugins from the locked Nixpkgs, so no TPM download or install shortcut is
needed. The status line now uses the shared palette.
An existing tmux server can reload it with `tmux source-file ~/.tmux.conf`.

## Customize and reuse

Edit `home/theme/palette.nix` for colors and font, or replace the included
wallpaper SVG. Configure keyboard layouts and monitor scaling in
`home/desktop/hyprland/default.nix`. The pinned Hyprland 0.55 release uses Lua;
Home Manager generates the Lua configuration from Nix settings.

Themes are applied with a rebuild. The appearance menu shows the current theme,
reloads the wallpaper, and controls idle locking and notifications.

The flake also exports `nixosModules.default`, `systemModules.default`, and
`homeManagerModules.default` for existing configurations. The system modules
expect `username` in `specialArgs`; the system-manager module also expects
`homeDirectory`. Keep the flake's Home Manager/Nixpkgs versions aligned when
importing those modules. Use `--flake .#aarch64-linux` or
`--flake .#x86_64-linux` to select an explicit architecture on either backend.

## Check and troubleshoot

```sh
nix flake check --impure --no-build
nix build .#checks.aarch64-linux.home --impure --no-link
nix build .#checks.aarch64-linux.desktop-config --impure --no-link
nix build .#checks.aarch64-linux.helper-behavior --impure --no-link
nix build .#checks.aarch64-linux.session-startup --impure --no-link
nix build .#checks.aarch64-linux.waybar --impure --no-link
nix build .#checks.aarch64-linux.system-manager-etc --impure --no-link
nix build .#checks.aarch64-linux.debian-session --impure --no-link
systemctl --user --failed
journalctl --user -u waybar -u walker -u elephant -u hypridle -b
```

Use `x86_64-linux` in the build attributes on an Intel/AMD machine. Flake checking
the NixOS outputs requires the real host configuration, or `NIXOS_CONFIG` pointing
at a test host file. The desktop configuration check runs Hyprland's verifier,
Foot's parser, and headless Neovim. The helper check uses mocked desktop tools to
test cancellation, clipboard handling, recording control, and power confirmation.
The session startup check loads the generated Home Manager profiles with unset
and existing cursor and data paths. It verifies the launcher reaches UWSM and
retains both the host's data directories and any inherited directories.
The system-manager check rejects dangling symlinks in the generated `/etc` tree
before activation.
The Debian session check verifies UWSM's user units and tests dconf writes through
the private activation bus and Debian's combined session-bus configuration.

Graphical login, lock/unlock, suspend, audio, screen sharing, and VM GPU behavior
still need testing on the target machine. No rebuild test can prove those from
evaluation alone. NixOS rollback uses its normal system generations;
system-manager rollback restores its managed profile. The Debian prerequisites
installed with apt remain Debian-managed.
