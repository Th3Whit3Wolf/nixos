{ config, lib, pkgs, ... }: 

let 
    vpnSec = s: config.age.secrets."secrets/vpn/${s}.age".path;
    vpnSecrets = lib.listToAttrs (lib.forEach [
        "expressVPN/auth.age"
        "expressVPN/ca.age"
        "expressVPN/cert.age"
        "expressVPN/key.age"
        "expressVPN/tls_auth.age"
        ] (vpnFile: {
            name = "secrets/vpn/${vpnFile}";
            value = { 
            file =  ../../../../secrets/vpn + "/${vpnFile}";
            };
        })
    );

in {
    config = {
        age.secrets = vpnSecrets;
        networking = {
            vpn = {
                enable = true;
                expressVPN = {
                    enable = true;
                    authUserPass = vpnSec "expressVPN/auth";
                    ca = vpnSec "expressVPN/ca";
                    cert = vpnSec "expressVPN/cert";
                    key = vpnSec "expressVPN/key";
                    tlsAuth = vpnSec "expressVPN/tls_auth";
                };
            };
            networkmanager.packages = [pkgs.networkmanager_openvpn];
        };
    };
}