#!/bin/sh
# THIS REMOVES THE OLD CONFIG

echo "Diff to be applied:"
diff --color=always -r /etc/nixos .
echo "Continue?"
read

sudo install --owner=root --group=root --mode=644 *.nix hostname homeipv6 /etc/nixos
sudo nixos-rebuild switch
