{ pkgs, ... }:
{
  home.packages = with pkgs; [
    taskwarrior
    tasksh
    (timewarrior.overrideDerivation (oldAttrs: { patches = oldAttrs.patches ++ [
      # Apply a patch that allows excluding tags (with -tag syntax)
      (pkgs.fetchpatch {
        url = "https://github.com/hiliev/timewarrior/commit/025b36c051c70fef2beeb456df5ef9ad9221f2e9.patch";
        hash = "sha256-yuH0zORS7xQ54MI25gB3kVPHQl4ebPw9F/CfZfzdW/g=";
      })
    ]; }))
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
