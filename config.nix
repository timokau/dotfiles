{
  allowUnfree = true;
  # allowUnfreePredicate = (pkg: elem (builtins.parseDrvName pkg.name).name [
  #   # unfree whitelist
  #   "spotify"
  # ]);
}
