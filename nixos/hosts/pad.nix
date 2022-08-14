{ config
, pkgs
, lib
, ...
}:

{
  imports = [
    ./battery.nix
  ];
  networking.hostName = "pad";

  # Mount /tmp in RAM.
  # Use 150% of RAM = 18G. We have 12G of RAM + 16G swap = 28G total available,
  # that leaves 10G even if /tmp is full -- in that case the tmpfs should be
  # moved to swap first.
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "150%";

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

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
  system.stateVersion = "22.05";
}
