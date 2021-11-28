{ config, lib, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      a52dec
      faac
      faad2
      flac
      gst_all_1.gst-libav
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-vaapi
      gst_all_1.gstreamer
      lame
      libde265
      libdv
      libmad
      libmpeg2
      libtheora
      libvorbis
      wavpack
      xvidcore
    ];
  };
}
