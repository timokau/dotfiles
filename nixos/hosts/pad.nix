{ config
, pkgs
, lib
, ...
}:

{
  imports = [
    ./battery.nix
    ./bluetooth.nix
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
