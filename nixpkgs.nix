let
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  nixpkgs-rev = "0470f36b02ef01d4f43c641bbf07020bcab71bf1";
in builtins.fetchTarball {
  name = "nixpkgs-${nixpkgs-rev}";
  url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-rev}.tar.gz";
}
