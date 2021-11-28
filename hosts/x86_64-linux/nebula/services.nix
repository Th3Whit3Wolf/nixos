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
  };

}
