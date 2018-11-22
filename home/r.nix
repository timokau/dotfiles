{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # some standard packages
    (rWrapper.override {
      packages = with rPackages; [
        dendextend
        rjson
        devtools
        ggplot2
        reshape2
        yaml
        optparse
        C50
        rpart
        lattice
      ];
    })
  ];
}
