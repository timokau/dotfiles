#!/bin/sh

NIXPKGS="$(nix eval --raw '(import ./nixpkgs.nix)')"

echo "Nixos config diff to be applied:"
diff --color=always -r /etc/nixos nixos
echo "Continue?"
read

# THIS REMOVES THE OLD CONFIG
sudo install --owner=root --group=root --mode=644 nixos/*.nix nixos/hostname nixos/homeipv6 nixpkgs.nix /etc/nixos

# set nixpkgs in NIX_PATH explicitly once, then it gets set as the default
sudo nixos-rebuild -I nixpkgs="$NIXPKGS" switch && nix run nixpkgs.home-manager -c home-manager -I nixpkgs="$NIXPKGS" -2 switch
