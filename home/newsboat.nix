{ pkgs, ... }:
{
  programs.newsboat.enable = true;
  # programs.newsboat.extraConfig = builtins.readFile ./newsboat/config;
  xdg.configFile."newsboat/config".source = ../newsboat/config;
  # FIXME
  # xdg.dataFile."newsboat" = {
  #   source = ~/state/newsboat;
  #   recursive = true;
  # };
  # newsboat considers this config, I consider it state
  xdg.configFile."newsboat/urls".source = ~/state/rss-urls;
}
