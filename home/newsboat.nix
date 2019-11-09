{ pkgs, ... }:
{
  programs.newsboat.enable = true;
  xdg.configFile."newsboat/config".source = ../newsboat/config;
  # newsboat considers this config, I consider it state
  xdg.configFile."newsboat/urls".source = ~/state/rss-urls;
}
