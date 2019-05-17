#!/usr/bin/env bash

set -e
set -o pipefail

# latest version of everything
export NIX_PATH=$HOME/.nix-defexpr/channels:$NIX_PATH # https://github.com/NixOS/nix/issues/2033
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update

nix run nixpkgs.home-manager -c home-manager switch
