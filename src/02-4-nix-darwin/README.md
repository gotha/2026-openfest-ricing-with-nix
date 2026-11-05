# Ricing tmux with Home Manager and nix-darwin

This builds on `02-3-ricing-tmux-multios`. Linux uses standalone Home Manager.
macOS uses nix-darwin with its Home Manager integration, so one rebuild applies
both the system preferences and the user's tmux configuration. Both Intel and
ARM machines are supported.

The structure separates the shared home configuration from macOS settings:

```text
flake.nix                  Inputs, platform detection, and rebuild tools
home/default.nix           Shared Home Manager configuration
home/tmux/default.nix      tmux, Git, fonts, and .tmux.conf
home/tmux/tmux.conf         tmux bindings, plugins, and theme
os/darwin/default.nix       nix-darwin settings and Option+Space shortcut
```

From the repository root:

```sh
cd src/02-4-ricing-tmux-multiarch-2
```

On Linux, activate as your regular user:

```sh
nix run . -- switch --flake .#default --impure
```

On macOS, activate for the existing user account through nix-darwin:

```sh
sudo nix run . -- switch --flake .#default --impure
```

The default package selects `home-manager` on Linux and `darwin-rebuild` on macOS
from the locked inputs. `--impure` allows reading the current architecture and
account environment. macOS uses `SUDO_USER` when invoked through sudo, so Home
Manager configures the invoking account. Its home directory is assumed to be
`/Users/<username>`.

After the first switch, you can use `home-manager switch --flake .#default --impure`
on Linux or `sudo darwin-rebuild switch --flake .#default --impure` on macOS. The
macOS configuration keeps the existing Nix installation with `nix.enable = false`,
including installations managed by Determinate Nix.

For an already managed Mac, integrate the shared home module and shortcut setting
into your existing nix-darwin configuration to retain its other settings.

The macOS module declares hotkey 60 under `system.defaults.CustomUserPreferences`
to select the previous input source with `Option+Space`. This frees `Ctrl+Space`
for tmux. Log out and back in if the shortcut does not update immediately.

This declarative version manages the whole `AppleSymbolicHotKeys` dictionary.
Other custom shortcut overrides in that dictionary are replaced; include any
overrides you want to retain alongside entry `60`. The previous example uses a
custom activation hook to merge only that entry.

The shared tmux module retains the plugins, yellow powerline theme, mouse support,
vi copy mode, and OSC 52 clipboard settings. It installs the same Nerd Font set as
`02-2-ricing-tmux`: Fira Code, Fira Mono, Hack, Iosevka, Noto, and Ubuntu.

Select `Iosevka Nerd Font Mono` or `FiraCode Nerd Font Mono` in your terminal's font
preferences. For SSH sessions, the font must be installed and selected on the
machine running the terminal emulator.

TPM installs its plugins under `~/.tmux/plugins` on the first launch, which needs
internet access. To install plugins manually, press `Ctrl+Space`, release both
keys, then press `Shift+I`.
