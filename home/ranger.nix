{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (ranger.overridePythonAttrs (oldAttrs: {
      propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ [
        pkgs.python3.pkgs.pillow
      ];
    }))
    ffmpegthumbnailer # for viedeo preview images
    file # for determining mimetypes
  ];

  xdg.configFile."ranger" = {
    source = ../ranger/.config/ranger;
    recursive = true;
  };
}
