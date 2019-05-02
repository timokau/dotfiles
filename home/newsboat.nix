{ pkgs, ... }:
{
  programs.newsboat.enable = true;
  xdg.configFile."newsboat/config".source = ../newsboat/config;
  xdg.configFile."newsboat/scripts/patreon-rss.py".source = ../newsboat/patreon-rss.py;
  # newsboat considers this config, I consider it state
  xdg.configFile."newsboat/urls".source = ~/state/rss-urls;
}
