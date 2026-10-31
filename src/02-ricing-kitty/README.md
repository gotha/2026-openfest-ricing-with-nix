# Ricing Kitty with Home Manager

Standalone Home Manager example for Linux and macOS. Installs Kitty and Iosevka
Nerd Font, and keeps cowsay and Neovim from the tmux example.

Kitty uses `Iosevka Nerd Font Mono` at size 12. The configuration is written to
`~/.config/kitty/kitty.conf`. Linux font discovery is enabled through fontconfig;
Home Manager registers fonts on macOS automatically.

From the repository root, activate as your regular user:

```sh
cd src/02-ricing-kitty
nix run . -- switch --flake .#default --impure
```

If Home Manager is already installed, use:

```sh
home-manager switch --flake .#default --impure
```

The flake detects the current architecture, username, and home directory, which
requires `--impure`. It uses the same pinned inputs as `02-ricing-tmux`.

After activation, launch `kitty` from a graphical session. Close and reopen
existing Kitty windows to load the new font.
