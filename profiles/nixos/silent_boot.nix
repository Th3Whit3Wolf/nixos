{ config, lib, ... }:

{
  config = {
    boot.kernelParams = [
      # Prevents unneccesary infor being written to stdout durring boot.
      "quiet"
      "udev.log_priority=3"
    ];
  };
}