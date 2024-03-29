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
    # Configure the stylus buttons to enable long press, right-click and
    # panning
    "configure-stylus-buttons" = ''
      # Emulate left-click when touching the screen with the stylus. This is the
      # default behavior, but by default touching the screen triggers a
      # ButtonRelease immediately after ButtonPress, regardless of whether or not
      # the screen is still touches. The "+" changes that behavior (release is
      # sent when the pen stops touching the screen).
      xsetwacom set "Wacom HID 527A Pen stylus" Button 1 "button +1"
      # Emulate scrolling with button 2
      xsetwacom set "Wacom HID 527A Pen stylus" Button 2 "pan"
      # Emulate right-click with the first button + pen touch (technically the
      # first button toggle the pen into eraser mode, which then triggers button
      # 1 of the eraser).
      xsetwacom set "Wacom HID 527A Pen eraser" Button 1 "button +3"
    '';
  };
  # Run autorandr on startup
  systemd.user.services.autorandr-init = {
    description = "Apply autorandr configuration once the graphical session is ready.";
    script = "${pkgs.autorandr}/bin/autorandr --change";
    serviceConfig.Type = "oneshot";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
  };

  # Support iio-sensor-proxy, required by the autorotate script
  hardware.sensor.iio.enable = true;

  # Default to internal audio, only use other outputs if explicitly chosen.
  hardware.pulseaudio.extraConfig = ''
    set-default-sink alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink
  '';

  systemd.user.services.autorotate = {
    description = "Rotate the screen depending on the current orientation.";
    script = let
      internal-display-name = "eDP-1";
      inputs-to-transform = [
        "Wacom HID 527A Finger touch"
        "Wacom HID 527A Pen stylus"
        "Wacom HID 527A Pen eraser"
      ];
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
        for input in ${lib.concatMapStrings (x: " " + (lib.escapeShellArg x)) inputs-to-transform}; do
          # $transform is not quoted on purpose since splitting is desired
          ${pkgs.xorg.xinput}/bin/xinput set-prop "$input" --type=float 'Coordinate Transformation Matrix' $transform
        done
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

