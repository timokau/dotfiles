{ config, pkgs, lib, ... }:
let
  cfg = config.emacs;
in
{
  options.emacs = {
    enable = lib.mkEnableOption "Emacs";
  };

  # Emacs and its plugins is configured with doom-emacs. That is not quite as
  # nice as using nix directly, but its relatively close since doom-emacs pins
  # all its packages. Doom saves us a lot of effort, so this is a compromise
  # for practicality's sake.
  config = let
    # Use flake-compat to get the outputs of nix-doom-emacs-unstraightened [1]
    # https://nixos.wiki/wiki/Flakes#Using_flakes_with_stable_Nix
    ndeu-flake-compat = (import (
      fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/ff81ac966bb2cae68946d5ed5fc4994f96d0ffec.tar.gz";
        sha256 = "19d2z6xsvpxm184m41qrpi1bplilwipgnzv9jy17fgw421785q1m";
    }) {
      src = (import ../npins).nix-doom-emacs-unstraightened.outPath;
    }).defaultNix;
    # Pass the nixpkgs that the nix-doom-emacs-unstraightened flake uses through
    # it's own overlay to get a nixpkgs version that has the ndeu packages.
    # This is hack, which is necessary because adding the overlay to
    # `nixpkgs.overlays` causes an infinite recursion for some reason and the
    # flake only gives direct access to doomEmacs, not emacsWithDoom (which
    # provides the standard emacs binaries).
    ndeu-nixpkgs = (ndeu-flake-compat.overlays.default ndeu-flake-compat.inputs.nixpkgs.legacyPackages."x86_64-linux" null);
    emacspkg = ndeu-nixpkgs.emacsWithDoom {
      doomDir = ../doom-emacs;
      doomLocalDir="~/.local/share/nix-doom-unstraightened";
      tangleArgs = ".";
    };
    # nix-doom-emacs-unstraightened does not provide org-capture
    org-capture = pkgs.writeScriptBin "org-capture" ''
      #!${pkgs.bash}/bin/bash
      ${ndeu-flake-compat.inputs.doomemacs}/bin/org-capture "$@"
    '';

    org-protocol-handler-script = pkgs.writeScript "handlerScript.sh" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.libnotify}/bin/notify-send --expire-time=1000 --urgency=low "Captured"
      exec ${emacspkg}/bin/emacsclient -- "$@"
    '';
    org-protocol-handler-registration = pkgs.makeDesktopItem {
      name = "org-protocol";
      exec = "${org-protocol-handler-script} %u";
      desktopName = "org-protocol";
      mimeTypes = ["x-scheme-handler/org-protocol"];
    };
  in lib.mkIf cfg.enable {
    programs.fish = {
      shellAliases = {
        # Emacs TUI
        em = "${emacspkg}/bin/emacsclient --tty";
        emg = "${emacspkg}/bin/emacsclient --create-frame --no-wait";
      };
    };
    home = {
      packages = with pkgs; [
        emacspkg # The emacs package, configured to use doom-emacs.
        # A desktop file to register emacsclient as a handler for org-protocol
        org-protocol-handler-registration
        org-capture
      ];
    };
    services.emacs = {
      enable = true;
      package = emacspkg;
      client.enable = true;
    };
  };
}
