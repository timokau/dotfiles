# Configuration for devices with intel graphics
{ config
, pkgs
, lib
, ...
}:

{
  # For hardware-accelerated video playback
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];
}
