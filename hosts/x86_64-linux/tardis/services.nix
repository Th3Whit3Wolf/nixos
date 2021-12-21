{ config, pkgs, unstable, ... }: {
  services = {
    openssh.enable = true;
    irqbalance.enable = true;
    plex = {
      enable = true;
      openFirewall = true;
    };
    Jellyfin = { 
      enable = true;
      openFirewall = true;
    };

    # Should stop charging after 60% battery
    udev.extraRules = ''
    ACTION=="add", KERNEL=="asus-nb-wmi", RUN+="${pkgs.bash}/bin/bash -c 'echo 60 > /sys/class/power_supply/BAT?/charge_control_end_threshold'"
    '';
  };

  # Should allow touch pad
  hardware.i2c.enable = true;
  systemd.services.asus-touchpad-numpad = {
    description = "Activate Numpad inside the touchpad with top right corner switch";
    documentation = ["https://github.com/mohamed-badaoui/asus-touchpad-numpad-driver"];
    path = [ pkgs.i2c-tools ];
    script = ''
      cd ${pkgs.fetchFromGitHub {
        owner = "mohamed-badaoui";
        repo = "asus-touchpad-numpad-driver";
        # These needs to be updated from time to time
        rev = "d80980af6ef776ee6acf42c193689f207caa7968";
        sha256 = "sha256-JM2wrHqJTqCIOhD/yvfbjLZEqdPRRbENv+N9uQHiipc=";
      }}
      # In the last argument here you choose your layout.
      ${pkgs.python3.withPackages(ps: [ ps.libevdev ])}/bin/python asus_touchpad.py ux433fa
    '';
    # Probably needed because it fails on boot seemingly because the driver
    # is not ready yet. Alternativly, you can use `sleep 3` or similar in the
    # `script`.
    serviceConfig = {
      RestartSec = "1s";
      Restart = "on-failure";
    };
    wantedBy = [ "multi-user.target" ];
  };
  /*
  systemd.services.battery-charge-threshold = {
    description = "Set the battery charge threshold";
    after = [ "multi-user.target" ];
    StartLimitBurst = 0;

    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      ExecStart =
        "${pkgs.bash}/bin/bash -c 'echo 60 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";

    wantedBy = "multi-user.target";
    };
  };*/
}