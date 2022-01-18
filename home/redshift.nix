{ config, pkgs, lib, ... }:
let
  cfg = config.redshift;
  brightness = {
    "DELL U2415" = {
      day = 50;
      transition = 25;
      night = 5;
    };
    "G276HL" = {
      day = 100;
      transition = 40;
      night = 1;
    };
  };
  # Snippet to be inserted into the `brightness.sh` hook.
  brightness_script = new_period: ''
    maybe_set_ddc "DEL" "DELL U2415" '${toString brightness."DELL U2415".${new_period}}'
    maybe_set_ddc_retry "ACR" "G276HL" '${toString brightness."G276HL".${new_period}}'
  '';
in
with lib;
{
  options.redshift = {
    enable = mkEnableOption "Redshift";
  };

  config = mkIf cfg.enable {
    home.file.".config/redshift/hooks/brightness.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        BRIGHTNESS_FEATURE_ID=10
        LOGFILE=/tmp/redshift-hook.log

        log() {
          # Add timestamp, log to file and stderr
          msg="$1"
          full_msg="$(${pkgs.coreutils}/bin/date -Is): $msg"
          echo "$full_msg" >> "$LOGFILE"
          echo "$full_msg" >&2
        }

        should_configure_ddc_display() {
          manufacturer="$1"
          model="$2"
          if ${pkgs.ddcutil}/bin/ddcutil --mfg "$manufacturer" --model "$model" get "$BRIGHTNESS_FEATURE_ID" >/dev/null 2>&1; then
            log "Configuring $model"
            return 0
          else
            log "Skipping $model (likely not connected)"
            return 1
          fi
        }

        set_ddc() {
          manufacturer="$1"
          model="$2"
          brightness="$3"
          ${pkgs.ddcutil}/bin/ddcutil --mfg "$manufacturer" --model "$model" set "$BRIGHTNESS_FEATURE_ID" "$brightness" >> "$LOGFILE" 2>&1
        }

        maybe_set_ddc() {
          if should_configure_ddc_display "$1" "$2"; then
            set_ddc "$1" "$2" "$3"
          fi
        }

        maybe_set_ddc_retry() {
          if should_configure_ddc_display "$1" "$2"; then
            while ! set_ddc "$1" "$2" "$3"; do
              log "Configuring $2 failed. Retrying."
              sleep 1
            done
          fi
        }


        # See [1] for the arguments of this hook.
        # [1] https://github.com/jonls/redshift/blob/490ba2aae9cfee097a88b6e2be98aeb1ce990050/src/hooks.c#L102
        event_type="$1"
        [[ "$event_type" != "period-changed" ]] && exit 0
        prv_period="$2"
        cur_period="$3"

        # See [1] for the possible period names.
        # https://github.com/jonls/redshift/blob/490ba2aae9cfee097a88b6e2be98aeb1ce990050/src/hooks.c#L36
        case "$cur_period" in
          none|daytime)
            log "Setting daytime brightness"
            ${brightness_script "day"}
            ;;
          transition)
            log "Setting transition brightness"
            ${brightness_script "transition"}
            ;;
          night)
            log "Setting night brightness"
            ${brightness_script "night"}
            ;;
        esac
      '';
    };
    services.redshift = {
      enable = true;
      latitude = "51.71667";
      longitude = "8.76667";
      temperature.night = 3000;
      temperature.day = 6000;
    };
  };
}
