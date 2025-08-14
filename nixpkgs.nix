let
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  nixpkgs-rev = "005433b926e16227259a1843015b5b2b7f7d1fc3";
in builtins.fetchTarball {
  name = "nixpkgs-${nixpkgs-rev}";
  url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-rev}.tar.gz";
}
