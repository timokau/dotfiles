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

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

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

  # Udev rule for battery warnings and emergency hibernation

  # Notifies when the internal battery (BAT0) Discharging, below 10% and a
  # battery event is triggered.

  # Battery events are triggered infrequently. Appears to be at 80, 20, 5, 4
  # and 1 percent on my machine.
  services.udev.extraRules = let
    notifyThreshold = 10;
    hibernateThreshold = 1;
    # Run a command as all users with active login sessions. This can for
    # example be used to dispatch notifications to all users.
    runCommandInUser = pkgs.writeScript "run-in-user-sessions.sh" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.systemd}/bin/loginctl list-sessions --output=short --no-legend | ${pkgs.gawk}/bin/awk '{print $1}' | while read session_id; do
        username=$(${pkgs.systemd}/bin/loginctl show-session --value --property=Name "$session_id")
        uid=$(${pkgs.systemd}/bin/loginctl show-session --value --property=User "$session_id")
        # Drop permissions, set up user session variables
        env \
          DISPLAY="$(${pkgs.systemd}/bin/loginctl show-session --value --property=Display "$session_id")" \
          PULSE_SERVER="/run/user/$uid/pulse/native" \
          DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
          ${pkgs.su}/bin/su --login --preserve-environment --command "$@" "$username"
      done
    '';
    # Notify the current user if the battery is low. Inspects the environment
    # variables POWER_SUPPLY_NAME, POWER_SUPPLY_STATUS and
    # POWER_SUPPLY_CAPACITY -> should be run within the context of an udev
    # battery event. Should be run within a user session, since it calls
    # notify-send.
    notifyUserIfBatteryLow = pkgs.writeScript "notify-user-if-battery-low.sh" ''
      #!${pkgs.bash}/bin/bash
      if [[ $POWER_SUPPLY_NAME == "BAT0" ]] && [[ $POWER_SUPPLY_STATUS == "Discharging" ]] && [[ -n $POWER_SUPPLY_CAPACITY ]] && [[ $POWER_SUPPLY_CAPACITY -le ${toString notifyThreshold} ]]; then
        ${pkgs.pulseaudio}/bin/paplay --server="$PULSE_SERVER" '${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/service-logout.oga'
        notify-send \
          --urgency=critical \
          --expire-time=5000 \
          --app-name='Battery warning' \
          "$POWER_SUPPLY_NAME low ($POWER_SUPPLY_STATUS): ''${POWER_SUPPLY_CAPACITY}%"
      fi
    '';
    # Handle a battery event, dispatching warning notifications and/or
    # hibernating if necessary.
    mainScript = pkgs.writeScript "handle-battery-event.sh" ''
      #!${pkgs.bash}/bin/bash
      # Executes notify-user.sh in the context of every running xsession as
      # the user that owns that session. Additionally sets the PULSE_SERVER
      # variable for use with paplay.

      # All of this should be given due to the udev trigger, but double check
      # anyway to avoid a hibernation loop if sometihng goes wrong.
      bail() {
        echo "$1" >&2
        exit 1
      }
      [[ $POWER_SUPPLY_NAME == "BAT0" ]] || bail "Power supply $POWER_SUPPLY_NAME"
      [[ -n $POWER_SUPPLY_CAPACITY ]] || bail "Capacity $POWER_SUPPLY_CAPACITY"

      ${runCommandInUser} ${lib.escapeShellArg notifyUserIfBatteryLow}

      # Hibernate when below the threshold. This will only happen one time once
      # the threshold is passed. Charging the battery resets this.
      if [[ $POWER_SUPPLY_STATUS == "Discharging" ]] && [[ $POWER_SUPPLY_CAPACITY -le ${toString hibernateThreshold} ]]; then
        if [[ ! -e /tmp/hibernate-lock ]]; then
          touch /tmp/hibernate-lock
          ${runCommandInUser} ${lib.escapeShellArg "notify-send --urgency=critical --app-name='Battery warning' 'Battery critical, hibernating'"}
          sleep 3
          ${pkgs.systemd}/bin/systemctl hibernate
        fi
      elif [[ -e /tmp/hibernate-lock ]]; then
        rm /tmp/hibernate-lock
      fi
    ''; in ''
      SUBSYSTEM=="power_supply", KERNEL=="BAT0", ACTION=="change", RUN+="${mainScript}"
    '';


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "22.05";
}
