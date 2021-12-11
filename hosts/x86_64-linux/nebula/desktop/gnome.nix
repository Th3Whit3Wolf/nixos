# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {
    "org/gnome/Connections" = {
      first-run = false;
    };

    "org/gnome/Lollypop" = {
      network-access-acl = 1048574;
      notification-flag = 2;
      window-maximized = false;
      window-position = [ 26 23 ];
      window-size = [ 851 600 ];
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
      window-position = mkTuple [ 0 0 ];
      window-size = mkTuple [ 2560 1408 ];
    };

    "org/gnome/control-center" = {
      last-panel = "background";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///persist/home/doc/.local/share/backgrounds/2021-11-28-21-16-06-mountain.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = false;
    };

    "org/gnome/desktop/input-sources" = {
      per-window = false;
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-im-module = "gtk-im-context-simple";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      lock-delay = "uint32 0";
      picture-options = "zoom";
      picture-uri = "file:///persist/home/doc/.local/share/backgrounds/2021-11-28-21-20-25-Rob%20Bye.jpg";
      primary-color = "#000000000000";
      secondary-color = "#000000000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/session" = {
      idle-delay = "uint32 300";
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

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-temperature = "uint32 2700";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [ "bigSur-StatusArea@ordissimo.com" "display-brightness-ddcutil@themightydeity.github.com" "blur-my-shell@aunetx" "native-window-placement@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "gsconnect@andyholmes.github.io" "user-theme@gnome-shell-extensions.gcampax.github.com" ];
      favorite-apps = [ "org.gnome.Calendar.desktop" "org.gnome.Nautilus.desktop" "firefox.desktop" "org.gnome.Lollypop.desktop" "Alacritty.desktop" ];
      welcome-dialog-last-shown-version = "41.1";
    };

    "org/gnome/shell/extensions/bigsur-statusarea" = {
      activate-spacing = false;
      items = "Calendar;1;1;calendar|Light;0;0;light|Night Light;0;0;nightlight|Volume;1;0;volume|Network;1;0;network|Bluetooth;1;0;bluetooth|Power;1;0;power|Notification;1;0;notification|User;1;0;user";
      separate-date-and-notification = true;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      animate-show-apps = true;
      apply-custom-theme = false;
      background-opacity = 0.72;
      custom-theme-running-dots-border-color = "rgb(255,255,255)";
      custom-theme-running-dots-color = "rgb(255,255,255)";
      custom-theme-shrink = false;
      customize-alphas = true;
      dash-max-icon-size = 48;
      dock-position = "BOTTOM";
      force-straight-corner = false;
      height-fraction = 0.5;
      icon-size-fixed = false;
      isolate-monitors = true;
      max-alpha = 0.75;
      middle-click-action = "launch";
      min-alpha = 9.0e-2;
      multi-monitor = true;
      preview-size-scale = 0.89;
      running-indicator-dominant-color = true;
      running-indicator-style = "DEFAULT";
      scroll-to-focused-application = true;
      shift-click-action = "minimize";
      shift-middle-click-action = "launch";
      show-apps-at-top = false;
      show-favorites = true;
      show-show-apps-button = true;
      show-trash = true;
      transparency-mode = "DYNAMIC";
      unity-backlit-items = true;
    };

    "org/gnome/shell/extensions/gsconnect" = {
      id = "f02b50ed-8d4d-4345-997b-3b2be5ade6b1";
      name = "nebula";
      show-indicators = false;
    };

    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = mkTuple [ 640 440 ];
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 157;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 26 23 ];
      window-size = mkTuple [ 1231 902 ];
    };

  };
}
