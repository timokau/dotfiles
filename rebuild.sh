#!/bin/sh
(cd nixos; ./apply.sh)
NIXPKGS="$(nix eval --raw '(import ./nixpkgs.nix)')"
# set nixpkgs in NIX_PATH explicitly once, then it gets set as the default
sudo nixos-rebuild -I nixpkgs="$NIXPKGS" switch && nix run nixpkgs.home-manager -c home-manager -I nixpkgs="$NIXPKGS" -2 switch
