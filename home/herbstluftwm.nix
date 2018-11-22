{ pkgs, ... }:
{
  home.packages = with pkgs; [
    sxhkd # I'm using a separate sxhkd configuration just for controlling the window manager
    i3lock # lock screen
    xtitle # TODO necessary?
    xautolock # lock when idle
    dzen2 # for the bar
  ];

  xdg.configFile."herbstluftwm" = {
    source = ../herbstluftwm/.config/herbstluftwm;
    recursive = true;
  };
}
