{ config, ... }: 

{
  config = {
    networking = {
      useDHCP = false;
      interfaces.enp4s0.useDHCP = true;
      firewall = {
        enable = true;
        #allowedTCPPorts = [ ];
        #allowedUDPPorts = [ ];
      };
    };
  };
}
