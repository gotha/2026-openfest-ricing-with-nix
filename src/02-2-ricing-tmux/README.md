# Ricing tmux with Home Manager

The `home/tmux` module is copied from `dotfiles/home-manager/tmux`. It installs tmux
and Git and manages `~/.tmux.conf` with the same bindings, plugins, and yellow
powerline theme as the dotfiles configuration.

The module also installs Iosevka Nerd Font, which includes the Powerline separator
glyphs used by the tmux theme. Linux font discovery is enabled through fontconfig;
Home Manager registers the font on macOS automatically.

Activate from the repository root:

```sh
cd src/02-2-ricing-tmux
nix run . -- switch --flake .#default --impure -b before-home-manager
```

The `home/bash` module configures Bash and manages `~/.bash_profile`, `~/.profile`,
and `~/.bashrc`. The backup flag keeps existing unmanaged files with a
`.before-home-manager` suffix when Home Manager takes over these files.

Home Manager loads its session variables through `.profile`, and `.bash_profile`
loads `.profile` and `.bashrc`. Interactive Bash shells source the installed Nix
profile script from `.bashrc`, for both multi-user and single-user installations.
For multi-user Nix, the configuration clears the inherited
`__ETC_PROFILE_NIX_SOURCED` flag first so Nix restores its paths even if Debian's
system profile reset `PATH`.

Keep Bash as the account's login shell. If you already changed it to Zsh, run
`chsh -s /bin/bash` before applying this configuration, then log out and back in.
Home Manager does not change the account's login shell, and tmux uses its normal
shell selection from `$SHELL` or the account's login shell.

After applying, open a new terminal or run `exec /bin/bash -l` in the current
terminal to load the managed configuration. Existing tmux panes can run the same
command. Start a fresh tmux server after changing the account's login shell.

Start tmux with `tmux`. The prefix is `Ctrl+Space`. Mouse support and vi copy mode
are enabled, and window numbering starts at 1.

After switching, select `Iosevka Nerd Font Mono` in your terminal's font
preferences and open a new terminal window. tmux uses the
terminal's font. If tmux runs on a remote machine over SSH, install and select the
font on the machine running the terminal emulator too. Installing it only on the
remote machine will not change how the local terminal renders the status bar.

TPM installs itself and the configured plugins under `~/.tmux/plugins` on the first
launch, which needs internet access. The configuration includes tmux-sensible,
tmux-pain-control, tmux-sessionist, tmux-themepack, vim-tmux-navigator, tmux-yank,
tmux-copycat, and tmux-resurrect, along with OSC 52 clipboard support.
