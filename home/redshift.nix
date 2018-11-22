{ pkgs, ... }:
{
  services.redshift = {
    enable = true;
    latitude = "51.71667";
    longitude = "8.76667";
    brightness.night = "0.7";
    temperature.night = 4000;
    temperature.day = 6000;
  };
}
