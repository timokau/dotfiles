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
    intel-vaapi-driver
    libva-vdpau-driver
    libvdpau-va-gl
  ];
}
