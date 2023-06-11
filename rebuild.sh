#!/bin/sh

echo "Nixos config diff to be applied:"
diff --color=always -r /etc/nixos nixos
echo "Continue?"
read

# This overwrites the old config. Old files are not removed automatically. If
# you remove a file from this list, you should delete it manually.
sudo install --owner=root --group=root --mode=644 nixos/*.nix nixos/server_address nixpkgs.nix /etc/nixos

echo "Rebuilding"

NIXPKGS="$(nix-instantiate --eval ./nixpkgs.nix | tr --delete '"' )"
# set nixpkgs in NIX_PATH explicitly once, then it gets encoded as the default in the system configuration
export NIX_PATH="nixpkgs=$NIXPKGS:$NIX_PATH"

# First build both systems together for increased parallelization
echo "Instantiating"

# home-manager requires its sources to be in the NIX_PATH. Installing it from
# nixpgks is not the preferred method of installation, which is why this is a
# bit complicated.
export HOME_MANAGER_PATH=$( nix-build --no-out-link "$NIXPKGS" -A home-manager.src )
export NIX_PATH="$NIX_PATH:home-manager=$HOME_MANAGER_PATH"
home_manager_system="$( nix-shell --packages home-manager --run 'home-manager --show-trace instantiate' )"
nixos_system="$( nix-instantiate -E '((import <nixpkgs/nixos>) {}).system' )"
[[ $? -ne 0 ]] && exit $?
echo "Rebuilding"
nix-build --no-link --show-trace $nixos_system $home_manager_system || exit $?

echo "Waiting for attention: Permission to switch"
while ! sudo echo "Sudo password cached"; do :; done

echo "Switching system"

# Now switch both systems. If the build succeeded, this hopefully won't fail
sudo nixos-rebuild -I nixpkgs="$NIXPKGS" switch
exit_code=$?

# This sometimes gets killed during system updates
systemctl --user restart keyboardconfig

echo "Switching home"
nix-shell --packages home-manager --run 'home-manager --show-trace switch' || exit $?

exit "$exit_code"
