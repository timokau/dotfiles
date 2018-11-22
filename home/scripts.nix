{ pkgs, ... }:
let
  inherit (pkgs) lib;

  # generate the contents of a wrapper file that roughly emulates nix-shell behaviour
  staticShell = scriptPath:
    let
      depFileResult = extractDeps scriptPath;
      depFileContents = lib.splitString "\n" (builtins.readFile depFileResult.depsFile);
      interpreter = lib.head depFileContents;
      deps = lib.tail depFileContents;
      pathStrings = lib.imap0 (i: v: (lib.attrByPath (lib.splitString "." v) v pkgs) + "/bin") deps;
    in
      if depFileResult.success then
        ''
          #! ${pkgs.bash}/bin/bash
          export PATH="${lib.concatStringsSep ":" pathStrings}:${lib.makeBinPath pkgs.stdenv.initialPath}"
          exec ${interpreter} ${scriptPath} "$@"
        ''
      else
        ''
          #! ${pkgs.bash}/bin/bash
          exec ${scriptPath} "$@"
        '';

  # take a `#! nix-shell -i ... -p ...` line and generate a file containing only the interpreter in the first line and the dependencies in the consecutive lines. I'm using a file here since I don't know of a better mechanism to "shell out" in nix.
  shebangLineToDepsFile = secondLine:
    let
      pythonProcessingScript = ''
          import sys
          args = [ arg.strip() for arg in sys.stdin.readlines()[1:] ] # skip executable name
          i = 0
          interpreter = None
          dependencies = []
          pFlagActive = False
          while i < len(args):
              cur = args[i]

              if cur[0] == '-':
                # new flag
                pFlagActive = False

              if pFlagActive:
                  dependencies += [ cur ]
              else:
                if cur == "-i":
                    interpreter = args[i+1]
                    i += 1
                elif cur == "-p":
                    pFlagActive = True

              i += 1

          if interpreter is None:
              sys.exit(1)

          # print in known order
          print(interpreter)
          for dep in dependencies:
              print(dep)
      '';
    in
      pkgs.runCommand "deps-file" {} ''
        # strip the `#!`
        secondLine="${secondLine}"
        shellArgs="''${secondLine:2}"

        # use xargs to parse the arguments (respecting shell quoting)
        xargs printf '%s\n' <<< "$shellArgs" \
        | ${pkgs.python3.interpreter} -c ${lib.escapeShellArg pythonProcessingScript} > "$out"
      '';

  # generate a file listing the interpreter and dependencies of a script
  extractDeps = scriptPath:
    let
      lines = lib.splitString "\n" (builtins.readFile scriptPath);
      shebangLine = lib.head lines;
      secondLine = lib.head (lib.tail lines);
      isNixShebang = lib.hasPrefix "#!" secondLine; # TODO improve this
    in
      {
        success = isNixShebang;
        depsFile = if isNixShebang then shebangLineToDepsFile secondLine else "";
      };
in
{
  home.file = let
    scripts = builtins.attrNames (builtins.readDir ../scripts/bin); # assumes there are no subdirectories
    fileToWrapper = basePath: fileName: {
      name = "bin/${fileName}";
      value = {
        text = staticShell "${basePath}/${fileName}";
        executable = true;
      };
    };
    scriptFiles = lib.imap0 (i: (fileToWrapper ../scripts/bin)) scripts;
  in
    builtins.listToAttrs scriptFiles;
}
