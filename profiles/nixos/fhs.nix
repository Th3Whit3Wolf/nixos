{ config, lib, pkgs, ... }:

{
    environment = {
        fhs = {
            enable = true;
            linkExes = true;
            linkLibs = true;
        };
        lsb = {
            enable = true;
            #enableDesktop = true;
            support32Bit = true;
        };
        sessionVariables.LD_LIBRARY_PATH = lib.mkForce "/lib";
        systemPackages = with pkgs; [
            pkg-config
            openssl
            openssl.dev
            freetype
            fontconfig
            expat
        ];
    };
}