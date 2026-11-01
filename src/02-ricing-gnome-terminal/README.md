# Ricing GNOME Terminal with Home Manager

Standalone Home Manager example for Linux. Installs GNOME Terminal and Iosevka Nerd
Font, and keeps cowsay and Neovim from the tmux example.

The default terminal profile, `Ricing`, uses `Iosevka Nerd Font Mono` at size 12.
The window theme is dark, with light text, a blue cursor, and contrasting selection
colors. ANSI black is set to gray so programs that request black text stay readable.
Font discovery is enabled through fontconfig.

Home Manager applies the profile through dconf. The profile opens a login shell so
new terminal windows load your login environment, including Nix's shell setup.

From the repository root, activate as your regular user in the Linux desktop session:

```sh
cd src/02-ricing-gnome-terminal
nix run . -- switch --flake .#default --impure
```

If Home Manager is already installed, use:

```sh
home-manager switch --flake .#default --impure
```

The flake detects the current architecture, username, and home directory, which
requires `--impure`. It supports `x86_64-linux` and `aarch64-linux`, and uses the same
pinned Nixpkgs and Home Manager revisions as `02-ricing-tmux`.

After activation, open a new GNOME Terminal window from the desktop application
menu or run `gnome-terminal` from a terminal in the graphical session.
