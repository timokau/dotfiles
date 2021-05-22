let
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  nixpkgs-rev = "d42cd445dde587e9a993cd9434cb43da07c4c5de";
in builtins.fetchTarball {
  name = "nixpkgs-${nixpkgs-rev}";
  url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-rev}.tar.gz";
}
