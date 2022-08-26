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

  # For touchscreen gestures, configured on a per-user basis through home-manager.
  services.touchegg.enable = true;

  # Autorandr is managed in the user config. This just adds system-wide hooks.
  services.autorandr.hooks.postswitch = {
    # Map stylus, eraser and regular touch to the internal screen
    "map-touch-input" = ''
      for input in "Wacom HID 527A Pen stylus" "Wacom HID 527A Finger touch" "Wacom HID 527A Pen eraser"; do
        xinput --map-to-output "$input" eDP-1
      done
    '';
  };

  # Support iio-sensor-proxy, required by the autorotate script
  hardware.sensor.iio.enable = true;
  systemd.user.services.autorotate = {
    description = "Rotate the screen depending on the current orientation.";
    script = let
      internal-display-name = "eDP-1";
      input-to-transform = "Wacom HID 527A Finger touch";
    in builtins.toString (pkgs.writeScript "auto-rotate.sh" ''
      #!${pkgs.bash}/bin/bash
      # Rotate the display and the input to normal/left-up/right-up/bottom-up
      rotate() {
        case "$1" in
          normal)
            transform="1 0 0 0 1 0 0 0 1"
            rotation="normal"
            ;;
          left-up)
            transform="0 -1 1 1 0 0 0 0 1"
            rotation="left"
            ;;
          right-up)
            transform="0 1 0 -1 0 1 0 0 1"
            rotation="right"
            ;;
          bottom-up)
            transform="-1 0 1 0 -1 1 0 0 1"
            rotation="inverted"
            ;;
        esac
        ${pkgs.xorg.xrandr}/bin/xrandr --output '${internal-display-name}' --rotate "$rotation"
        # $transform is not quoted on purpose since splitting is desired
        ${pkgs.xorg.xinput}/bin/xinput set-prop '${input-to-transform}' --type=float 'Coordinate Transformation Matrix' $transform
      }

      # Parse monitor-sensor output to extract the orientation and pass it to
      # the `rotate` function
      ${pkgs.iio-sensor-proxy}/bin/monitor-sensor | while read line; do
        case "$line" in
          '=== Has accelerometer (orientation: '*')')
            orientation="$( echo "$line" | sed -e 's/^.*(orientation: \(.*\))$/\1/' )"
            rotate "$orientation"
            ;;
          'Accelerometer orientation changed: '*)
            orientation="$( echo "$line" | sed -e 's/^.*changed: \(.*\)$/\1/' )"
            rotate "$orientation"
            ;;
        esac
      done
    '');
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "22.05";
}

