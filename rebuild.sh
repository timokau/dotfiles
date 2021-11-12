#!/bin/sh

echo "Nixos config diff to be applied:"
diff --color=always -r /etc/nixos nixos
echo "Continue?"
read

# This overwrites the old config. Old files are not removed automatically. If
# you remove a file from this list, you should delete it manually.
sudo install --owner=root --group=root --mode=644 nixos/*.nix nixos/server_address nixpkgs.nix /etc/nixos

nix_cmd() {
	nix --extra-experimental-features nix-command "$@"
}
nixpkgs_hm() {
	# Run home-manager from the nixpkgs in NIX_PATH.
	nix_cmd run -f '<nixpkgs>' home-manager "$@"
}

echo "Rebuilding"

NIXPKGS="$(nix_cmd eval --raw --file ./nixpkgs.nix)"
# set nixpkgs in NIX_PATH explicitly once, then it gets encoded as the default in the system configuration
export NIX_PATH="nixpkgs=$NIXPKGS:$NIX_PATH"

# First build both systems using nix 2
echo "Instantiating"
home_manager_system="$( nixpkgs_hm --show-trace instantiate )"
nixos_system="$( nix-instantiate -E '(with import <nixpkgs/nixos> {}; system)' )"
[[ $? -ne 0 ]] && exit $?
echo "Rebuilding"
nix_cmd build --no-link --show-trace $nixos_system $home_manager_system || exit $?

echo "Waiting for attention: Permission to switch"
while ! sudo echo "Sudo password cached"; do :; done

echo "Switching system"

# Now switch both systems. If the build succeeded, this hopefully won't fail
sudo nixos-rebuild -I nixpkgs="$NIXPKGS" switch

# This sometimes gets killed during system updates
systemctl --user restart keyboardconfig

echo "Switching home"
nixpkgs_hm switch
