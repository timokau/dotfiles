{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (neovim.override {
      configure = {
        vam = {
          knownPlugins = pkgs.vimPlugins;
          pluginDictionaries = [
            # pandoc
            { names = [ "vim-pandoc" "vim-pandoc-syntax" ]; filename_regex = "^.pdc\$"; }
            # latex
            { name = "vimtex"; ft_regex = "^tex$"; }
            { name = "rust-vim"; ft_regex = "^rust\$"; }
            # { name = "vim-nix"; filename_regex = "\.nix$"; }
            { name = "vim-nix"; filename_regex = "\.nix$"; }
            { name = "gruvbox"; }
            { name = "CSApprox"; }
            # { name = "LanguageClient-neovim"; ft_regex = "^rust\$"; }
          ];
        };
        customRC = builtins.replaceStrings [
          "'rustup'"
        ] [
          "'${pkgs.rustup}/bin/rustup'"
        ] (builtins.readFile ../nvim/.config/nvim/init.vim);
        # customRC = ''
        #   # custom config
        # '';
      };
    })
  ];

  # programs.neovim = {
  #   enable = true;
  #   # configure = TODO
  # };
}
