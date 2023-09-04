{ config, pkgs, lib, ... }:
let
  cfg = config.herbstluftwm;
in
with lib;
{
  options.herbstluftwm = {
    enable = mkEnableOption "Herbstluftwm window manager";
  };

  config = mkIf cfg.enable {
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

    xsession.enable = true;
    xsession.windowManager.command = 
    let
      # Fix tests with recent xorg versions.
      # https://github.com/NixOS/nixpkgs/pull/253271
      patched-hlwm = pkgs.herbstluftwm.overrideAttrs (old: {
        patches = old.patches ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/herbstluftwm/herbstluftwm/commit/1a6e8ee24eac671569f54bfec22ab47ff285a52c.patch";
            hash = "sha256-srulWJQ9zTR4Kdxo40AdHND4nexDe2PDSR69yWsOpVA=";
          })
        ];
      });
    in ''
      PATH="${patched-hlwm}/bin:$PATH" herbstluftwm
    '';
  };
}
