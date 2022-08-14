{ config, pkgs, lib, ... }:
let
  cfg = config.kitty;
in
with lib;
{
  options.kitty = {
    enable = mkEnableOption "Kitty terminal emulator";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kitty # terminal emulator
    ];

    # see ${pkgs.kitty}/share/doc/kitty/html/_downloads/kitty.conf for options
    xdg.configFile."kitty/kitty.conf".text = ''
      scrollback_lines 10000

      shell ${pkgs.fish}/bin/fish

      font_size 11.0

      include ${pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dexpota/kitty-themes/b1abdd54ba655ef34f75a568d78625981bf1722c/themes/Tomorrow.conf";
        hash = "sha256-jZPchAiZj52VD4ZdJAo/JNBxC42IiembtHyt44rXSnw=";
      }}

      close_on_child_death yes
      confirm_os_window_close 0

      kitty_mod ctrl+shift
      map ctrl+plus change_font_size current +1.0
      map ctrl+minus change_font_size current -1.0
      map ctrl+0 change_font_size current 0

      map ctrl+shift+plus change_font_size all +1.0
      map ctrl+shift+minus change_font_size all -1.0
      map ctrl+shift+0 change_font_size all 0

      map kitty_mod+x kitten hints
      map kitty_mod+s kitten hints
      map kitty_mod+c copy_to_clipboard
      map kitty_mod+v paste_from_clipboard

      map kitty_mod+k scroll_line_up
      map kitty_mod+j scroll_line_down
      map kitty_mod+h show_scrollback
      map kitty_mod+e pipe @text overlay ${pkgs.neovim}/bin/nvim -
      map kitty_mod+p>shift+f kitten hits --type path --program -
      map kitty_mod+p>shift+h kitten hits --type hash --program -
    '';
  };
}
