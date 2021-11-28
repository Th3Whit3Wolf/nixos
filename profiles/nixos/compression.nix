{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      commonsCompress
      lhasa
      lrzip
      lzop
      p7zip
      pbzip2
      pigz
      unrar
      unzip
    ];
  };
}
