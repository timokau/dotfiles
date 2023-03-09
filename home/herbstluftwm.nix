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
    xsession.windowManager.command = let
      herbstluftwm = (pkgs.herbstluftwm.overrideAttrs (oldAttrs: {
        # gcc12 compatibility, https://github.com/NixOS/nixpkgs/pull/220133
        patches = oldAttrs.patches ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/herbstluftwm/herbstluftwm/commit/8678168c7a3307b1271e94974e062799e745ab40.patch";
            hash = "sha256-uI6ErfDitT2Tw0txx4lMSBn/jjiiyL4Qw6AJa/CTh1E=";
          })
        ];
      }));
    in ''
      PATH="${herbstluftwm}/bin:$PATH" herbstluftwm
    '';
  };
}
