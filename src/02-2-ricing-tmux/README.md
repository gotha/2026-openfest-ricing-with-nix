# Ricing tmux with Home Manager

The `home/tmux` module is copied from `dotfiles/home-manager/tmux`. It installs tmux
and Git and manages `~/.tmux.conf` with the same bindings, plugins, and yellow
powerline theme as the dotfiles configuration.

The module also installs the Nerd Font families from `dotfiles/config/fonts.nix`:
Fira Code, Fira Mono, Hack, Iosevka, Noto, and Ubuntu. These include the Powerline
separator glyphs used by the tmux theme. Linux font discovery is enabled through
fontconfig; Home Manager registers the fonts on macOS automatically.

Activate from the repository root:

```sh
cd src/02-ricing-tmux
nix run . -- switch --flake .#default --impure
```

Start tmux with `tmux`. The prefix is `Ctrl+Space`. Mouse support and vi copy mode
are enabled, and window numbering starts at 1.

After switching, select `Iosevka Nerd Font Mono` or `FiraCode Nerd Font Mono` in
your terminal's font preferences and open a new terminal window. tmux uses the
terminal's font. If tmux runs on a remote machine over SSH, install and select the
font on the machine running the terminal emulator too. Installing it only on the
remote machine will not change how the local terminal renders the status bar.

TPM installs itself and the configured plugins under `~/.tmux/plugins` on the first
launch, which needs internet access. The configuration includes tmux-sensible,
tmux-pain-control, tmux-sessionist, tmux-themepack, vim-tmux-navigator, tmux-yank,
tmux-copycat, and tmux-resurrect, along with OSC 52 clipboard support.
