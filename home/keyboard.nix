{ pkgs, ... }:
let
  snippets = {
    "switch-capslock-and-control" = ''
      ${pkgs.xmodmap}/bin/xmodmap - <<EOF
        ! remove the keys to be remapped from the relevant modifier maps
        remove Lock = Caps_Lock
        remove Control = Control_L

        ! swap the keys
        keysym Control_L = Caps_Lock
        keysym Caps_Lock = Control_L

        ! re-add the remapped keys to the relevant modifier maps
        add Lock = Caps_Lock
        add Control = Control_L
      EOF
      ${pkgs.xcape}/bin/xcape -e 'Control_L=Escape'
    ''
      };
  genereateRemapping = key: remapping: ''
    ${pkgs.xmodmap}/bin/xmodmap -e 
  '';
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
