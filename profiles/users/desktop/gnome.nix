{ config, pkgs, lib, ... }: 
let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {
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
      last-panel = "applications";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "'file:///home/doc/.local/share/backgrounds/2021-11-28-21-20-25-Rob%20Bye.jpg'";
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
      picture-uri = "'file:///home/doc/.local/share/backgrounds/2021-11-28-21-20-25-Rob%20Bye.jpg'";
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

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      favorite-apps = [ "org.gnome.Calendar.desktop" "org.gnome.Nautilus.desktop" "firefox.desktop" "org.gnome.Lollypop.desktop" "Alacritty.desktop" ];
      welcome-dialog-last-shown-version = "41.1";
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