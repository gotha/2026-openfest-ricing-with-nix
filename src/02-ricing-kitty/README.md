# Ricing Kitty with Home Manager

Standalone Home Manager example for Linux and macOS. Installs Kitty and Iosevka
Nerd Font, and keeps cowsay and Neovim from the tmux example.

Kitty uses `Iosevka Nerd Font Mono` at size 12. The configuration is written to
`~/.config/kitty/kitty.conf`. Linux font discovery is enabled through fontconfig;
Home Manager registers fonts on macOS automatically.

On Linux, Kitty is wrapped with nixGL's Mesa wrapper so it can find compatible
OpenGL drivers on Debian and other distributions. This wrapper is also used when
launching Kitty from the desktop application menu. macOS uses the native package.

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
requires `--impure`. Nixpkgs and Home Manager use the same pinned revisions as
`02-ricing-tmux`. nixGL follows the same Nixpkgs input to keep graphics libraries
compatible with Kitty.

After activation, launch `kitty` from a graphical session. Close and reopen
existing Kitty windows to load the new font.

If the VM's virtual GPU cannot provide an OpenGL context, try Mesa's software
renderer from a terminal in the VM's desktop:

```sh
LIBGL_ALWAYS_SOFTWARE=1 kitty
```

Kitty needs an X11 or Wayland display. An SSH session without display forwarding
cannot open a terminal window on its own.
