{ username, ... }:
{
  # Debian already manages Nix and the accounts in /etc/passwd.
  nix.enable = false;
  services.userborn.enable = false;

  # Describe the existing account for Home Manager and its per-user packages.
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
  };

  home-manager.users.${username} =
    { lib, ... }:
    {
      dconf.settings = {
        "org/gnome/desktop/input-sources".xkb-options = [ "caps:escape" ];

        "org/gnome/desktop/peripherals/keyboard" = {
          repeat = true;
          delay = lib.hm.gvariant.mkUint32 210;
          repeat-interval = lib.hm.gvariant.mkUint32 15;
        };

        "org/gnome/desktop/wm/keybindings" = {
          # Free Alt+Space for the previous input source, matching Option+Space on macOS.
          activate-window-menu = [ ];
          switch-input-source-backward = [ "<Alt>space" ];
        };
      };
    };
}
