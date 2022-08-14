{ config
, pkgs
, lib
, ...
}:

{
  imports = [
    ./battery.nix
    ./bluetooth.nix
    ./intel-graphics.nix
    ./touchpad.nix
  ];
  networking.hostName = "yoga";

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  services.xserver.wacom.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "22.05";
}

