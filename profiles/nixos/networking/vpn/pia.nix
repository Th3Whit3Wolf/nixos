{ config, pkgs, ... }: 

{
    config = {
        age.secrets = {
            "secrets/vpn/pia.age" = {
                file = ../../../../secrets/vpn/pia.age;
            };
        };
        networking = {
            vpn = {
                enable = true;
                pia = {
                    enable = true;
                    authUserPass = config.age.secrets."secrets/vpn/pia.age".path;
                };
            };
            networkmanager.packages = [pkgs.networkmanager_openvpn];
        };
    };
}