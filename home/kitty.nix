{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kitty # terminal emulator
  ];

  # see ${pkgs.kitty}/share/doc/kitty/html/_downloads/kitty.conf for options
  xdg.configFile."kitty/kitty.conf".text = ''
    scrollback_lines 10000

    font_size 11.0

    foreground #dddddd
    background #000000

    close_on_child_death yes

    kitty_mod ctrl+shift
    map ctrl+plus change_font_size all +2.0
    map ctrl+minus change_font_size all -2.0
    map ctrl+0 change_font_size all 0
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
}
