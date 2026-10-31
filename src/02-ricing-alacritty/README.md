# Ricing Alacritty with Home Manager

Standalone Home Manager example for Linux and macOS. Installs Alacritty and Iosevka
Nerd Font, and keeps cowsay and Neovim from the tmux example.

Alacritty uses `Iosevka Nerd Font Mono` at size 12. The configuration is written to
`~/.config/alacritty/alacritty.toml`. Linux font discovery is enabled through fontconfig;
Home Manager registers fonts on macOS automatically.

On Linux, Alacritty is wrapped with nixGL's Mesa wrapper so it can find compatible
OpenGL drivers on Debian and other distributions. This wrapper is also used when
launching Alacritty from the desktop application menu. macOS uses the native package.

From the repository root, activate as your regular user:

```sh
cd src/02-ricing-alacritty
nix run . -- switch --flake .#default --impure
```

If Home Manager is already installed, use:

```sh
home-manager switch --flake .#default --impure
```

The flake detects the current architecture, username, and home directory, which
requires `--impure`. Nixpkgs and Home Manager use the same pinned revisions as
`02-ricing-tmux`. nixGL follows the same Nixpkgs input to keep graphics libraries
compatible with Alacritty.

After activation, launch `alacritty` from a graphical session.

If the VM's virtual GPU cannot provide an OpenGL context, try Mesa's software
renderer from a terminal in the VM's desktop:

```sh
LIBGL_ALWAYS_SOFTWARE=1 alacritty
```

Alacritty needs an X11 or Wayland display. An SSH session without display forwarding
cannot open a terminal window on its own.
