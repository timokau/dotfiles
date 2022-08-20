{ pkgs, ... }:
let
  # Generate a hook script that delegates to a repository-local script.
  delegateToLocalHook = name: {
    executable = true;
    text = ''
      if [[ -x "./.git/hooks/${name}" ]]; then
        exec "./.git/hooks/${name}"
      fi
    '';
  };
in {
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        light = true;
      };
    };
    aliases = {
      co = "checkout";
      # create a quick new feature branch in a separate dir
      wa = ''
        !sh -c 'git worktree prune && git worktree add -b $0 ../$0 ''${1:-upstream/master} && cd ../$0'
      '';
      find-merge = ''
        !sh -c 'commit=$0 && branch=''${1:-HEAD} && (git rev-list $commit..$branch --ancestry-path | cat -n; git rev-list $commit..$branch --first-parent | cat -n) | sort -k2 -s | uniq -f1 -d | sort -n | tail -1 | cut -f2'
      '';
      track = ''
        !git push --set-upstream timokau "$(git symbolic-ref --short HEAD)"
      '';
      bisect-edit = ''
        !sh -c 'git bisect log > /tmp/bisect-log && nvim /tmp/bisect-log && git bisect reset && git bisect replay /tmp/bisect-log'
      '';
      # better overview, less details
      lg = "log --color --graph --oneline --decorate";
    };
    extraConfig = {
      # use ssh-ident to start ssh-agent as necessary
      core.sshCommand = "BINARY_SSH=${pkgs.openssh}/bin/ssh ${pkgs.ssh-ident}/bin/ssh-ident";
      core.hooksPath = "~/.config/git/hooks"; # Use global hooks. Overrides local hooks.
      commit.verbose = true; # show diff when committing
    };
    # signing = TODO
    userEmail = "timokau@zoho.com";
    userName = "Timo Kaufmann";
  };

  # I want to add a global hook but still execute local hooks as well.
  # Unfortunately the `hooksPath` option overrides local hooks. The following
  # adds some delegation scripts. There are a lot of git hooks and this just
  # covers a few of them. Other local hooks will not be called. A nicer
  # solution will be possible if config-based-hooks is merged [1].
  # [1] https://lore.kernel.org/git/YQHAasrmcbdiCDQF@google.com/T/#m248c2de60a10879d24691e1b835bcf46af2aca09
  home.file.".config/git/hooks/commit-msg" = delegateToLocalHook "commit-msg";
  home.file.".config/git/hooks/pre-commit" = delegateToLocalHook "pre-commit";
  home.file.".config/git/hooks/post-commit" = delegateToLocalHook "post-commit";
  home.file.".config/git/hooks/pre-rebase" = delegateToLocalHook "pre-rebase";
  home.file.".config/git/hooks/prepare-commit-msg" = delegateToLocalHook "prepare-commit-msg";
  # Check for a "NOPUSH" marker in the commit message before pushing. Abort if
  # one exists.
  home.file.".config/git/hooks/pre-push" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash

      local_hook() {
        # Call a local hook if it exists.
        if [[ -x "./.git/hooks/pre-push" ]]; then
          exec "./.git/hooks/pre-push"
        fi
      }

      # The format is specified here:
      # https://git-scm.com/docs/githooks#_pre_push (accessed 2021-07-31).
      while read local_ref local_obj remote_ref remote_obj; do
        pushed_objects_range="$remote_obj..$local_obj"
        # Foreign ref does not exist yet 
        if [[ "$remote_obj" == "0000000000000000000000000000000000000000" ]]; then
          pushed_objects_range="$local_obj"
        fi

        nopush_commit="$(git rev-list --grep 'NOPUSH' --max-count=1 "$pushed_objects_range")"
        if [[ -n "$nopush_commit" ]]; then
          echo "Attempting to push commit with NOPUSH marker. Aborting." >&2
        fi

        # Send stdin through to stdout to forward to the local hook (if one exists)
        echo "$local_ref $local_obj $remote_ref $remote_obj"
      done | local_hook
    '';
  };
}
