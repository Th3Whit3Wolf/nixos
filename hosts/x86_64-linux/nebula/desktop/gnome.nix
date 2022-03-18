# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {
    "org/gnome/control-center" = {
      last-panel = "mouse";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/doc/.local/share/backgrounds/2021-11-28-21-20-25-mountain.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/input-sources" = {
      per-window = false;
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      gtk-im-module = "gtk-im-context-simple";
    };

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      disable-microphone = false;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/doc/.local/share/backgrounds/2021-11-28-21-20-25-mountain.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = "uint32 900";
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
      network-monitor-gio-name = "";
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = true;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      workspaces-only-on-primary = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      welcome-dialog-last-shown-version = "41.1";
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/terminal/legacy/profiles:" = {
      list = [ "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" "e5075ad8-af87-42a2-abcf-2cf357324db8" "d85f9e37-3f5e-4987-b16a-82500f5f4dc2" "1570f75a-765e-48fa-8695-44484340963c" "85abcf43-55b0-46a2-b7d9-1f79e2460265" ];
    };

    "org/gnome/terminal/legacy/profiles:/:1570f75a-765e-48fa-8695-44484340963c" = {
      palette = [ "rgb(0,0,0)" "rgb(228,86,73)" "rgb(80,161,79)" "rgb(152,104,1)" "rgb(64,120,242)" "rgb(166,38,164)" "rgb(1,132,188)" "rgb(160,161,167)" "rgb(92,99,112)" "rgb(224,108,117)" "rgb(80,161,79)" "rgb(152,104,1)" "rgb(64,120,242)" "rgb(166,38,164)" "rgb(1,132,188)" "rgb(255,255,255)" ];
      use-theme-colors = false;
      visible-name = "One Light";
    };

    "org/gnome/terminal/legacy/profiles:/:85abcf43-55b0-46a2-b7d9-1f79e2460265" = {
      background-color = "rgb(40,42,54)";
      bold-color = "rgb(110,70,164)";
      bold-color-same-as-fg = false;
      foreground-color = "rgb(248,248,242)";
      palette = [ "rgb(38,38,38)" "rgb(227,86,167)" "rgb(66,230,108)" "rgb(228,243,74)" "rgb(155,107,223)" "rgb(230,71,71)" "rgb(117,215,236)" "rgb(239,165,84)" "rgb(122,122,122)" "rgb(255,121,198)" "rgb(80,250,123)" "rgb(241,250,140)" "rgb(189,147,249)" "rgb(255,85,85)" "rgb(139,233,253)" "rgb(255,184,108)" ];
      use-theme-colors = false;
      visible-name = "Dracula";
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      background-color = "rgb(41,43,46)";
      bold-is-bright = true;
      cursor-background-color = "rgb(227,222,221)";
      cursor-colors-set = true;
      cursor-foreground-color = "rgb(33,32,38)";
      cursor-shape = "ibeam";
      foreground-color = "rgb(178,178,178)";
      palette = [ "rgb(10,8,20)" "rgb(242,36,31)" "rgb(103,177,29)" "rgb(177,149,29)" "rgb(58,129,195)" "rgb(163,29,177)" "rgb(33,184,199)" "rgb(178,178,178)" "rgb(66,68,74)" "rgb(223,32,28)" "rgb(41,160,173)" "rgb(219,116,46)" "rgb(57,128,194)" "rgb(44,148,115)" "rgb(107,48,98)" "rgb(104,104,104)" ];
      use-theme-colors = false;
      visible-name = "Space Dark";
    };

    "org/gnome/terminal/legacy/profiles:/:d85f9e37-3f5e-4987-b16a-82500f5f4dc2" = {
      background-color = "rgb(40,44,52)";
      bold-color = "rgb(171,178,191)";
      bold-color-same-as-fg = false;
      foreground-color = "rgb(171,178,191)";
      palette = [ "rgb(0,0,0)" "rgb(224,108,117)" "rgb(152,195,121)" "rgb(209,154,102)" "rgb(97,175,239)" "rgb(198,120,221)" "rgb(86,182,194)" "rgb(171,178,191)" "rgb(92,99,112)" "rgb(224,108,117)" "rgb(152,195,121)" "rgb(209,154,102)" "rgb(97,175,239)" "rgb(198,120,221)" "rgb(86,182,194)" "rgb(255,255,255)" ];
      use-theme-colors = false;
      visible-name = "One Dark";
    };

    "org/gnome/terminal/legacy/profiles:/:e5075ad8-af87-42a2-abcf-2cf357324db8" = {
      background-color = "rgb(251,248,239)";
      bold-is-bright = true;
      cursor-background-color = "rgb(16,10,20)";
      cursor-colors-set = true;
      cursor-foreground-color = "rgb(239,234,233)";
      cursor-shape = "ibeam";
      foreground-color = "rgb(101,83,112)";
      palette = [ "rgb(210,206,218)" "rgb(242,36,31)" "rgb(103,177,29)" "rgb(177,149,29)" "rgb(58,129,195)" "rgb(163,29,177)" "rgb(33,184,199)" "rgb(101,83,112)" "rgb(239,234,233)" "rgb(223,32,28)" "rgb(41,160,173)" "rgb(219,116,46)" "rgb(57,128,194)" "rgb(44,148,115)" "rgb(107,48,98)" "rgb(160,148,162)" ];
      use-theme-colors = false;
      visible-name = "Space Light";
    };

    "org/gtk/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 1.0 0.721569 ]) (mkTuple [ 0.627451 0.580392 ]) (mkTuple [ 0.407843 0.407843 ]) (mkTuple [ 0.698039 0.698039 ]) (mkTuple [ 0.815686 0.811765 ]) (mkTuple [ 0.419608 0.188235 ]) (mkTuple [ 0.2 0.780392 ]) (mkTuple [ 0.129412 0.721569 ]) ];
      selected-color = mkTuple [ true 1.0 ];
    };

    "org/gtk/settings/file-chooser" = {
      clock-format = "12h";
    };

  };
}
