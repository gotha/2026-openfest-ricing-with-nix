# Ricing macOS, Debian, and NixOS

This copies `02-4-ricing-tmux-multiarch-2` and adds system-manager for Debian
and a NixOS configuration. Each system imports the same Home Manager module,
so its switch also applies the user's tmux configuration, packages, and fonts.
Both Intel/AMD and ARM machines are supported.

```text
flake.nix                  Inputs, configurations, and rebuild tools
home/default.nix           Shared Home Manager configuration
home/tmux/default.nix      tmux, Git, fonts, and .tmux.conf
home/tmux/tmux.conf         tmux bindings, plugins, and theme
os/darwin/default.nix       nix-darwin preferences and Option+Space shortcut
os/debian/default.nix       system-manager settings for an existing Debian user
os/nixos/default.nix        Extends the installed NixOS configuration
```

From the repository root:

```sh
cd src/02-5-ricing-multiarch
```

| System | Flake output | Rebuild tool |
| --- | --- | --- |
| macOS | `darwinConfigurations.default` | `darwin-rebuild` |
| Debian | `systemConfigs.default` | `system-manager` |
| NixOS | `nixosConfigurations.default` | `nixos-rebuild` |

On macOS, activate for the existing user account:

```sh
sudo nix run . -- switch --flake .#default --impure
```

On Debian with Nix installed, run as your regular user:

```sh
nix run . -- switch --flake .#default --sudo --nix-option pure-eval false
```

System-manager imports Home Manager's NixOS module and activates it through a
`home-manager-<username>` systemd service. Debian continues to manage its own
accounts and Nix installation, with `services.userborn.enable = false` and
`nix.enable = false`. The account must already exist, with its home at
`/home/<username>`. Adjust `os/debian/default.nix` for a different home directory.
Log out and back in after the first switch so the desktop and terminals pick up
the per-user package path at `/etc/profiles/per-user/<username>/bin`.

On an installed NixOS system, activate with the explicitly named rebuild tool:

```sh
sudo nix run .#nixos-rebuild -- switch --flake .#default --impure
```

The NixOS module imports `/etc/nixos/configuration.nix` to retain the machine's
hardware, filesystems, bootloader, account settings, and `system.stateVersion`.
That file must be the installed system's configuration, including its hardware
configuration import. It must not import this flake back into itself. The rebuild
uses the Nixpkgs 26.05 version pinned in this example.

For a configuration stored elsewhere, pass its absolute path:

```sh
sudo env NIXOS_CONFIG=/path/to/configuration.nix \
  nix run .#nixos-rebuild -- switch --flake .#default --impure
```

For an existing flake-based NixOS setup, you can instead add `./home` and the
Home Manager integration to that flake's existing host configuration.

The default package selects system-manager on Linux and darwin-rebuild on macOS.
NixOS uses `.#nixos-rebuild` explicitly. The tools come from the locked inputs;
they do not need to be installed first. Home Manager is integrated into each
system configuration, so future changes use the same system switch command.

The configuration reads the current architecture and user environment.
`--impure` permits this for nix-darwin and NixOS. System-manager forwards the
equivalent setting with `--nix-option pure-eval false`. Under sudo, `SUDO_USER`
selects the invoking account. macOS assumes its home is `/Users/<username>`.
The Linux outputs are available on Linux and the Darwin output on macOS.

The macOS module retains the preferences from the copied example and keeps the
existing Nix installation with `nix.enable = false`. For an already managed Mac,
merge these modules into the existing nix-darwin configuration to retain its
other settings.

Hotkey 60 under `system.defaults.CustomUserPreferences` selects the previous
input source with `Option+Space`, freeing `Ctrl+Space` for tmux. Log out and back
in if the shortcut does not update immediately. This setting manages the whole
`AppleSymbolicHotKeys` dictionary. Include any other shortcut overrides you want
to retain alongside entry `60`.

The shared tmux module retains the plugins, yellow powerline theme, mouse
support, vi copy mode, and OSC 52 clipboard settings. It installs the same Nerd
Font set as the previous example: Fira Code, Fira Mono, Hack, Iosevka, Noto, and
Ubuntu. Select `Iosevka Nerd Font Mono` or `FiraCode Nerd Font Mono` in your
terminal's font preferences. For SSH sessions, install and select the font on
the machine running the terminal emulator.

TPM installs its plugins under `~/.tmux/plugins` on the first launch, which needs
internet access. To install plugins manually, press `Ctrl+Space`, release both
keys, then press `Shift+I`.
