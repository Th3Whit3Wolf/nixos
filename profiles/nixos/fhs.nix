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
            enableDesktop = true;
            support32Bit = true;
        };
    };
}