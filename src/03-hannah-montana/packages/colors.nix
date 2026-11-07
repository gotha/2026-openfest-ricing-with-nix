let
  plum = "72,32,63";
  muted = "131,91,123";
  rose = "180,43,120";
  colors = background: alternate: {
    BackgroundNormal = background;
    BackgroundAlternate = alternate;
    DecorationFocus = rose;
    DecorationHover = "215,100,172";
    ForegroundNormal = plum;
    ForegroundInactive = muted;
    ForegroundActive = rose;
    ForegroundLink = "141,40,121";
    ForegroundVisited = "115,67,168";
    ForegroundNegative = "177,45,98";
    ForegroundNeutral = "155,98,18";
    ForegroundPositive = "38,115,71";
  };
in
{
  General = {
    Name = "Hannah Montana Pink";
    ColorScheme = "HannahMontanaPink";
    shadeSortColumn = true;
  };
  KDE.contrast = 4;
  "Colors:Window" = colors "255,240,247" "247,230,245";
  "Colors:View" = colors "255,249,253" "250,235,247";
  "Colors:Button" = colors "255,216,235" "245,199,227";
  "Colors:Header" = colors "237,179,217" "226,182,238";
  "Colors:Header][Inactive" = colors "243,213,233" "246,225,241";
  "Colors:Tooltip" = colors "255,243,252" "247,230,245";
  "Colors:Selection" = (colors rose "166,41,121") // {
    ForegroundNormal = "255,250,254";
    ForegroundInactive = "255,220,241";
    ForegroundActive = "255,250,254";
    ForegroundLink = "255,239,174";
    ForegroundVisited = "235,215,255";
    DecorationFocus = "255,199,233";
    DecorationHover = "255,220,241";
  };
  "Colors:Complementary" = (colors "84,39,102" "102,55,122") // {
    ForegroundNormal = "255,240,248";
    ForegroundInactive = "220,185,220";
    ForegroundActive = "255,194,230";
    ForegroundLink = "255,194,230";
    ForegroundVisited = "216,190,255";
    DecorationFocus = "243,154,207";
    DecorationHover = "255,194,230";
  };
  "ColorEffects:Disabled" = {
    Color = muted;
    ColorAmount = 0;
    ColorEffect = 0;
    ContrastAmount = 0.65;
    ContrastEffect = 1;
    IntensityAmount = 0.1;
    IntensityEffect = 2;
  };
  "ColorEffects:Inactive" = {
    Enable = false;
    ChangeSelectionColor = true;
    Color = "226,182,238";
    ColorAmount = 0.025;
    ColorEffect = 2;
    ContrastAmount = 0.1;
    ContrastEffect = 2;
    IntensityAmount = 0;
    IntensityEffect = 0;
  };
  WM = {
    activeBackground = "233,163,207";
    activeBlend = "237,179,217";
    activeForeground = plum;
    inactiveBackground = "239,214,233";
    inactiveBlend = "246,225,241";
    inactiveForeground = muted;
  };
}
