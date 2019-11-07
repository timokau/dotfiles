#!/bin/sh
(cd nixos; ./apply.sh)
# twice to apply nix-path update
sudo nixos-rebuild switch && sudo nixos-rebuild switch && home-manager switch
