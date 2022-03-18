{ config, lib, pkgs, ... }:

{
    # this is needed to get a bridge with DHCP enabled
    virtualisation = {
        libvirtd.enable = true;
        docker.enable = true;

        virtualbox.host = {
            enable = true;
            enableExtensionPack = true;
        };
    };

    user.extraGroups.vboxusers.members = [ "doc"];
}