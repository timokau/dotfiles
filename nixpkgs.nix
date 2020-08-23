let
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  nixpkgs-rev = "c59ea8b8a0e7f927e7291c14ea6cd1bd3a16ff38";
in builtins.fetchTarball {
  name = "nixpkgs-${nixpkgs-rev}";
  url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-rev}.tar.gz";
}
