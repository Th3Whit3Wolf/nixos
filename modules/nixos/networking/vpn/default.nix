{ config, lib, pkgs, ... }:

with lib;

let
    cfg = config.networking.vpn;
in
{
    imports = [
        ./pia
        ./expressVPN
    ];
    options = {
        networking.vpn = {
            enable = lib.mkEnableOption "Erase you darlings";
        };
    };
}
