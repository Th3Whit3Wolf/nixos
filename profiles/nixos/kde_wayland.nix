{ config, pkgs, unstable, ... }: {
  environment = {
    noXlibs = true;
    systemPackages = with pkgs; [
      konsole
      kde-gtk-config
      libsForQt5.kdeconnect-kde
    ];
  };
  programs.kdeconnect.enable = true;
  services = {
    environment.noXlibs = true;
    environment.systemPackages = with pkgs; [
      konsole
      kde-gtk-config
      libsForQt5.kdeconnect-kde
    ];
    xserver = {
      enable = true;
      displayManager.sddm = {
        enable = true;
        settings.Wayland.SessionDir =
          "${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions";
      };
      desktopManager.plasma5 = {
        enable = true;
        supportDDC = true;
      };
    };
  };

}
