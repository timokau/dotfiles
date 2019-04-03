{ config, pkgs, lib, ... }:
let
  cfg = config.redshift;
in
with lib;
{
  options.redshift = {
    enable = mkEnableOption "Redshift";
  };

  config = mkIf cfg.enable {
    services.redshift = {
      enable = true;
      latitude = "51.71667";
      longitude = "8.76667";
      brightness.night = "0.5";
      temperature.night = 3000;
      temperature.day = 6000;
    };
  };
}
