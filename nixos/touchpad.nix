# Configuration for devices with a touchpad
{ config
, pkgs
, lib
, ...
}:

{
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true;
      scrollButton = 2;
      scrollMethod = "twofinger";
    };
  };
}
