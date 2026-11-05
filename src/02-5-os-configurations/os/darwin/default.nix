{ username, ... }:
{
  # Use the existing Nix installation, including Determinate Nix.
  nix.enable = false;

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";
  system = {
    stateVersion = 6;
    keyboard = {
      nonUS.remapTilde = true; # remap tilde to non-us
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    defaults = {
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        _FXShowPosixPathInTitle = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        CreateDesktop = false;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.24;
        minimize-to-application = true;
        orientation = "left";
        show-process-indicators = true;
        show-recents = false;
        wvous-tl-corner = 2; # top left hot corner - mission control
        persistent-apps = [
          "/System/Applications/System Settings.app"
          "/Applications/Safari.app"
        ];
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 14;
        KeyRepeat = 1;
        _HIHideMenuBar = true;
      };
      trackpad = {
        Clicking = true; # tap to cick
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      # Global-domain (`-g` / NSGlobalDomain) keys that nix-darwin exposes no
      # typed option for — macOS Tahoe "Liquid Glass" tuning. Set via
      # CustomUserPreferences, equivalent to `defaults write -g <key> ...`.
      # Floats (4.0 / 8.0) match the original `-float` writes.
      CustomUserPreferences.NSGlobalDomain = {
        NSSplitViewItemSidebarDefaultsToFloatingAppearance = false;
        NSSplitViewItemGlassMinimumCornerRadius = 4.0;
        NSConvolutionOverride1 = 8.0;
      };
    };
  };

  system.defaults.CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."60" = {
    enabled = true;
    value = {
      # Space character, Space key code, Option modifier mask.
      parameters = [
        32
        49
        524288
      ];
      type = "standard";
    };
  };
}
