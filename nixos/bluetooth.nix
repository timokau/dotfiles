# Configuration for bluetooth-enabled devices
{ config
, pkgs
, lib
, ...
}:

{
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    # config = {};
  };
  services.blueman.enable = true;
  programs.dconf.enable = true; # used by blueman
  hardware.pulseaudio = {
    configFile = pkgs.runCommand "default.pa" {} ''
      # Automatically switch audio profile when microphone access is requested
      # We need to modify the default configuration, since it already loads
      # module-bluetooth-policy
      sed 's/load-module module-bluetooth-policy$/load-module module-bluetooth-policy auto_switch=2/' ${pkgs.pulseaudio}/etc/pulse/default.pa > "$out"
    '';
    extraConfig = ''
      # Automatically switch the default to a new sink or source. Useful for
      # bluetooth headsets.
      load-module module-switch-on-connect
    '';
  };
}
