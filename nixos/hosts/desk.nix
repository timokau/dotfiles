{ config
, pkgs
, lib
, ...
}:

{
  networking.hostName = "desk";

  # configure static monitor setup on desk
  services.xserver.xrandrHeads = [
    {
      output = "HDMI-3";
      primary = true;
      monitorConfig = ''
        Option "Position" "2280 417"
        Option "PreferredMode" "1920x1080"
      '';
    }
    {
      output = "DisplayPort-3";
      monitorConfig = ''
        Option "Rotate" "left"
        Option "Position" "1080 70"
        Option "PreferredMode" "1920x1200"
      '';
    }
  ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.03";
}
