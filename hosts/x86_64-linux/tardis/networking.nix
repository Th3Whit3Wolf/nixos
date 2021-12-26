{ config, ... }: 

{
  config = {
    networking = {
      useDHCP = false;
      interfaces.wlp1s0.useDHCP = true;
      firewall = {
        enable = true;
        #allowedTCPPorts = [ ];
        #allowedUDPPorts = [ ];
      };
    };
  };
}
