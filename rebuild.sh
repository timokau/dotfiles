#!/bin/sh

echo "Nixos config diff to be applied:"
diff --color=always -r /etc/nixos nixos
echo "Continue?"
read

# THIS REMOVES THE OLD CONFIG
sudo install --owner=root --group=root --mode=644 nixos/*.nix nixos/hostname nixos/homeipv6 nixpkgs.nix /etc/nixos

echo "Rebuilding"

NIXPKGS="$(nix eval --raw '(import ./nixpkgs.nix)')"
# set nixpkgs in NIX_PATH explicitly once, then it gets encoded as the default in the system configuration
export NIX_PATH="nixpkgs=$NIXPKGS:$NIX_PATH"

# First build both systems using nix 2
echo "Instantiating"
home_manager_system="$( nix run nixpkgs.home-manager -c home-manager --show-trace instantiate )"
[[ $? -ne 0 ]] && exit $?
echo "Rebuilding"
nix build --no-link --show-trace '(with import <nixpkgs/nixos> { }; system)' $home_manager_system || exit $?

echo "Switching system"

# Now switch both systems. If the build succeeded, this hopefully won't fail
sudo nixos-rebuild -I nixpkgs="$NIXPKGS" switch

echo "Switching home"
nix run nixpkgs.home-manager -c home-manager -2 switch

# This sometimes gets killed during system updates
systemctl --user restart keyboardconfig
