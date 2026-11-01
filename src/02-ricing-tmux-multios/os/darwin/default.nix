{ lib, pkgs, ... }:
let
  inputSourceShortcut = lib.generators.toPlist { escape = true; } {
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
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.activation.setMacOSInputSourceShortcut = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Hotkey 60 selects the previous input source. Merge only this entry so other
      # customized keyboard shortcuts remain in AppleSymbolicHotKeys.
      run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys \
        -dict-add 60 ${lib.escapeShellArg inputSourceShortcut}
    '';
  };
}
