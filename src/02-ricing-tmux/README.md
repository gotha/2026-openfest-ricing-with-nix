# Ricing tmux with Home Manager

The `home/tmux` module is copied from `dotfiles/home-manager/tmux`. It installs tmux
and Git and manages `~/.tmux.conf` with the same bindings, plugins, and yellow
powerline theme as the dotfiles configuration.

Activate from the repository root:

```sh
cd src/02-ricing-tmux
nix run . -- switch --flake .#default --impure
```

Start tmux with `tmux`. The prefix is `Ctrl+Space`. Mouse support and vi copy mode
are enabled, and window numbering starts at 1.

TPM installs itself and the configured plugins under `~/.tmux/plugins` on the first
launch, which needs internet access. The configuration includes tmux-sensible,
tmux-pain-control, tmux-sessionist, tmux-themepack, vim-tmux-navigator, tmux-yank,
tmux-copycat, and tmux-resurrect, along with OSC 52 clipboard support.
