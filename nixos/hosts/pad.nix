{ config
, pkgs
, lib
, ...
}:

{
  networking.hostName = "pad";

  # Mount /tmp in RAM.
  # Use 150% of RAM = 18G. We have 12G of RAM + 16G swap = 28G total available,
  # that leaves 10G even if /tmp is full -- in that case the tmpfs should be
  # moved to swap first.
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "150%";

  services.tlp = {
    enable = true;
    settings = {
      # Stop charging at 80%, start again at 75%.
      START_CHARGE_THRESH_BAT0=75;
      STOP_CHARGE_THRESH_BAT0=80;
      START_CHARGE_THRESH_BAT1=75;
      STOP_CHARGE_THRESH_BAT1=80;
      # Thresholds may be changed temporarily (fullcharge). Restore them when unplugging.
      RESTORE_THRESHOLDS_ON_BAT=1;
    };
  };
  # Required by TLP for ThinkPad battery calibration
  boot = {
    kernelModules = ["acpi_call"];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  services.xserver.dpi = 120;

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

  # For hardware-accelerated video playback
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
  ];

  services.xserver.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true;
      scrollButton = 2;
      scrollMethod = "twofinger";
    };
  };


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";
}
