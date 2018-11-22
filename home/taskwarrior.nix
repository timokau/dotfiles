{ pkgs, ... }:
{
  home.packages = with pkgs; [
    taskwarrior
    tasksh
    timewarrior
  ];

  xdg.configFile."task" = {
    # TODO .config/task/server
    recursive = true;
    source = ../taskwarrior/.config/task;
  };
  home.file.".taskrc".source = ../taskwarrior/taskrc; # points to the ~/.config folder
  xdg.dataFile."task/dark-green-256.theme".source = ../taskwarrior/.local/share/task/dark-green-256.theme; # todo fetch from net

}
