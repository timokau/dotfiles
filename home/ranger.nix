{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ranger
    ffmpegthumbnailer # for viedeo preview images
    file # for determining mimetypes
  ];

  xdg.configFile."ranger" = {
    source = ../ranger/.config/ranger;
    recursive = true;
  };
}
