let
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  nixpkgs-rev = "5bc2962319ca6ccbd0033c95d3e00c9fde1b67ff";
in builtins.fetchTarball {
  name = "nixpkgs-${nixpkgs-rev}";
  url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-rev}.tar.gz";
}
