{ config
, pkgs
, lib
, ...
}:

{
  networking.hostName = "pad";

  # mount /tmp in RAM. Don't do this on pad, as the machine tends to run out of ram.
  boot.tmpOnTmpfs = true;

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
