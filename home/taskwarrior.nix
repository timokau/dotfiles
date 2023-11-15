{ pkgs, ... }:
{
  home.packages = with pkgs; [
    taskwarrior
    tasksh
    timewarrior
  ];

  systemd.user.services.timewarrior-stop = {
    Unit = {
      Description = "Stop Timewarrior tracking on logout";
      # Run ExitStop when default.target is no longer active.
      PartOf = ["default.target"];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${pkgs.timewarrior}/bin/timew stop";
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };

  xdg.configFile."task" = {
    # TODO .config/task/server
    recursive = true;
    source = ../taskwarrior/.config/task;
  };
  home.file.".local/share/task/hooks/on-modify.relative-recur".source = ../taskwarrior/hooks/on-modify.relative-recur;
  xdg.dataFile."task/dark-green-256.theme".source = ../taskwarrior/.local/share/task/dark-green-256.theme; # todo fetch from net

}
