{ pkgs, ... }:
let
  pluginRules = with pkgs.vimPlugins; [
    {
      p = vim-pandoc;
      r = "autocmd PlugAutoload BufReadPre,BufNewFile *.md,*.pdc :packadd vim-pandoc";
    }
    {
      p = vim-pandoc-syntax;
      r = "autocmd PlugAutoload BufReadPre,BufNewFile *.md,*.pdc :packadd vim-pandoc";
      config = ''
        " Continue pandoc enumerations when hitting return in insert mode
        autocmd FileType pandoc call Pandocsettings()

        function! Pandocsettings()
          setlocal comments +=:-
          setlocal formatoptions +=r
          setlocal colorcolumn=0
          setlocal spelllang=de_20
        endfun
      '';
    }
    {
      p = vimtex;
      startup = true;
      # r = ''
      #   autocmd PlugAutoload FileType tex :packadd vimtex
      # '';
      config = ''
        let g:vimtex_view_method="zathura"
        let g:vimtex_indent_on_ampersands=0
        let g:vimtex_indent_on_ampersands=0
        let g:vimtex_quickfix_open_on_warning=0
        let latexmk_options = '-pdf -verbose -file-line-error -synctex=1 -interaction=nonstopmode'
        command! LatexShellescape let g:vimtex_latexmk_options = latexmk_options . ' -shell-escape'
        command! LatexShellescapeOff let g:vimtex_latexmk_options = latexmk_options

        " Ignore spelling inside tabular {}
        fun! TexNoSpell()
          syntax region texNoSpell
            \ start="\\thref{"rs=s
            \ end="}\|%stopzone\>"re=e
            \ contains=@NoSpell,texStatement,texHperref
          syntax region texNoSpell
            \ start="\\coordinate"rs=s
            \ end=")\|%stopzone\>"re=e
            \ contains=@NoSpell,texStatement
          syntax region texNoSpell
            \ start="\\begin{tabular}{"rs=s
            \ end="}\|%stopzone\>"re=e
            \ contains=@NoSpell,texBeginEnd
          syntax match texTikzParen /(.\+)/ contained contains=@NoSpell transparent
          syntax region texTikz
            \ start="\\begin{tikzpicture}"rs=s
            \ end="\\end{tikzpicture}\|%stopzone\>"re=e
            \ keepend
            \ transparent
            \ contains=texStyle,@texPreambleMatchGroup,texTikzParen
          syntax region texNoSpellBrace
            \ start="\\begin{tikzpicture}{"rs=s
            \ end="}\|%stopzone\>"re=e

          syntax match texStatement '\\setcounter' nextgroup=texNoSpellBraces
          syntax match texStatement '\\newcounter' nextgroup=texNoSpellBraces
          syntax match texStatement '\\value' nextgroup=texNoSpellBraces
          syntax region texNoSpellBraces matchgroup=Delimiter start='{' end='}' contained contains=@NoSpell
        endfun
        autocmd BufRead,BufNewFile *.tex :call TexNoSpell()
      '';
    }
    {
      p = rust-vim;
      r = ''
        autocmd PlugAutoload FileType rust :packadd rust-vim
      '';
      config = ''
        " Run rustfmt on save
        let g:rustfmt_command='${pkgs.rustfmt}/bin/rustfmt' 
        let g:rustfmt_autosave = 1
      '';
    }
    {
      p = LanguageClient-neovim;
      r = ''
        autocmd PlugAutoload FileType rust :packadd LanguageClient-neovim
      '';
      config = ''
        let g:LanguageClient_serverCommands = {
          \'rust': ['${pkgs.rustup}', 'run', 'nightly', 'rls']
          \ }
        let g:LanguageClient_autoStart = 1

        augroup lc_bindings
          autocmd!
          autocmd Filetype rust LanguageClientStart
          autocmd Filetype rust nnoremap <buffer> gD <Plug>RacerShowDocumentation
          autocmd Filetype rust nnoremap <buffer> <silent> K :call LanguageClient_textDocument_hover()<CR>
          autocmd Filetype rust nnoremap <buffer> <silent> gd :call LanguageClient_textDocument_definition()<CR>
          autocmd Filetype rust nnoremap <buffer> <silent> <leader>r :call LanguageClient_textDocument_rename()<CR>
        augroup END
      '';
    }
    {
      p = vim-nix;
      r = ''
        autocmd PlugAutoload BufReadPre,BufNewFile *.nix :packadd vim-nix
      '';
    }
    {
      # toggle comment with gc
      p = vim-commentary;
      startup = true;
    }
    {
      # surround stuff, e.g. ysiw) to surround a word with parentheses
      p = vim-surround;
      startup = true;
      config = ''
        " surround with latex command
        let g:surround_{char2nr('c')} = "\\\1command\1{\r}"
      '';
    }
    {
      # show git diff in gutter
      p = vim-gitgutter;
      startup = true;
    }
    {
      # personal wiki (`:VimwikiIndex`)
      p = vimwiki;
      startup = true;
      config = ''
        let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
        " no default mappings please
        nnoremap <silent> <leader>zw <Plug>VimwikiIndex
        nnoremap <silent> <leader>zt <Plug>VimwikiTabIndex
        nnoremap <silent> <leader>zs <Plug>VimwikiUISelect
        nnoremap <silent> <leader>zi <Plug>VimwikiDiaryIndex
      '';
    }
    {
      # snippets
      p = ultisnips;
      startup = true;
      config = ''
        " Trigger configuration. <tab> interferes with YouCompleteMe
        let g:UltiSnipsExpandTrigger="<c-j>"
        let g:UltiSnipsJumpForwardTrigger="<c-j>"
        let g:UltiSnipsJumpBackwardTrigger="<c-k>"
        let g:UltiSnipsEditSplit="vertical"
        " FIXME
        "let g:UltiSnipsSnippetsDir=vimdir . "/UltiSnips"
        let g:UltiSnipsEnableSnipMate=0
      '';
    }
    {
      # highlight possible motion targets
      p = vim-easymotion;
      startup = true;
      config = ''
        map , <Plug>(easymotion-prefix)
        map ,/ <Plug>(easymotion-sn)
        omap ,/ <Plug>(easymotion-tn)
      '';
    }
    {
      # autocompletion
      p = deoplete-nvim;
      startup = true;
      config = ''
        let g:deoplete#enable_at_startup = 1
        let g:deoplete#enable_ignore_case = 1
        let g:deoplete#enable_smart_case = 1
        let g:deoplete#enable_camel_case = 1
        let g:deoplete#enable_refresh_always = 1
        let g:deoplete#enable_fuzzy_completion = 1
        let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
        let g:deoplete#omni#input_patterns.java = ['[^. \t0-9]\.\w*',
                                                  \'[^. \t0-9]\->\w*',
                                                  \'[^. \t0-9]\::\w*',
                                                  \]

        " Hide preview window after completion
        augroup deoplete_preview
	      autocmd!
	      autocmd CompleteDone * pclose!
        augroup END
      '';
    }
    {
      # autocompletion
      p = deoplete-jedi;
      startup = true;
      config = ''
        let g:deoplete#sources#jedi#show_docstring = 1
      '';
    }
    {
      # better statusbar
      p = vim-airline;
      startup = true;
      config = ''
        let g:airline#extensions#whitespace#mixed_indent_algo = 2
      '';
    }
    {
      # linting
      p = neomake;
      startup = true;
      config = ''
        augroup neomake_plugin
          autocmd!
          if has('nvim')
            " autocmd! BufWritePost * Neomake
            " autocmd! BufWritePost *.rs Neomake! clippy
          endif
        augroup END
        let g:neomake_python_enabled_makers = ['python', 'pyflakes', 'pylint']
        let g:neomake_tex_enabled_makers = ['chktex'] " no lacheck
        let g:neomake_sty_enabled_makers = ['chktex'] " no lacheck
        " Disabled warnings:
        " - command terminated with space (1) (I *want* to terminate some commands with space)
        " - wrong length of dash (8) (may or may not be right)
        " - should use \cdots to achieve an ellipsis (11) (I want to decide myself)
        " - interword spacing (12) (may or may not be right)
        " - intersentence spacing (13) (may or may not be right)
        " - mathmode on at end (16) (doesn't work)
        " - no ''' (23) (I use ' as a variable differentiator, not just for quoting)
        " - might want to put this between {} (25) (is confused by references with _)
        " - space before punctuation (26) (i want space before :=)
        " - should use space with parenthesis (36) (I don't want to use space)
        " - vertical rules in tables (44) (I don't think they are _always_ ugly)
        let g:neomake_tex_chktex_args = ['--nowarn=1', '--nowarn=8', '--nowarn=11', '--nowarn=12', '--nowarn=13', '--nowarn=16', '--nowarn=23', '--nowarn=25', '--nowarn=26', '--nowarn=36', '--nowarn=44']
      '';
    }
    {
      # show docstrings
      p = echodoc;
      startup = true;
      config = ''
        let g:echodoc_enable_at_startup = 1
      '';
    }
    {
      startup = true;
      p = pkgs.symlinkJoin {
        name = "fzf-vim";
        paths = [
          fzf-vim
          fzfWrapper
        ];
      };
      config = ''
        " Ignore non-text filetypes / generated files
        let fzf_ignores = ""
        "for ign in ['class', 'pdf', 'fdb_latexmk', 'aux', 'fls', 'synctex.gz', 'nav', 'snm', 'zip']
          "let fzf_ignores = fzf_ignores . " --ignore='*." . ign . "'"
        "endfor
        let $FZF_DEFAULT_COMMAND = 'ag --nocolor'.fzf_ignores.' --files-with-matches --follow --depth=-1 --hidden --search-zip -g "" 2>/dev/null'

        if exists(':terminal')
          augroup fzf
            autocmd!
            " BufEnter isn't triggered when the terminal is first opened
            autocmd TermOpen term://*fzf* tunmap <ESC><ESC>
            autocmd BufEnter term://*fzf* tunmap <ESC><ESC>
            autocmd BufLeave term://*fzf* tnoremap <silent> <ESC><ESC> <C-\><C-n>G:call search(".", "b")<CR>$
          augroup END
        endif

        nnoremap <silent> <leader>f :Files<CR>
        nnoremap <silent> <leader>a :Buffers<CR>
        nnoremap <silent> <leader>; :BLines<CR>
        nnoremap <silent> <leader>. :Lines<CR>
        nnoremap <silent> <leader>o :BTags<CR>
        nnoremap <silent> <leader>O :Tags<CR>
        nnoremap <silent> <leader>: :Commands<CR>
        nnoremap <silent> <leader>? :History<CR>
        nnoremap <silent> <leader>/ :execute 'Ag ' . input('Ag/')<CR>
        nnoremap <silent> <leader>gl :Commits<CR>
        nnoremap <silent> <leader>ga :BCommits<CR>

        imap <C-x><C-f> <plug>(fzf-complete-file-ag)
        imap <C-x><C-l> <plug>(fzf-complete-line)
      '';
    }
    {
      startup = true;
      p = vim-fugitive;
    }
  ];
  pluginRc = "augroup PlugAutoload\n"
    + pkgs.lib.concatStringsSep "\n" (map (pluginRule: pluginRule.r or "") pluginRules)
    + pkgs.lib.concatStringsSep "\n" (map (pluginRule: (pluginRule.config or "")) pluginRules);
in
{
  home.packages = with pkgs; [
    (neovim.override {
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # colorschemes
            gruvbox
            base16-vim
            #fzfWrapper # TODO ask upstream
          ] ++ map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: pluginRule.startup or false) pluginRules);
          opt = map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: !(pluginRule.startup or false)) pluginRules);
        };
        customRC = pluginRc + builtins.replaceStrings [
          "'rustup'"
        ] [
          "'${pkgs.rustup}/bin/rustup'"
        ] (builtins.readFile ../nvim/.config/nvim/init.vim);
        # customRC = ''
        #   # custom config
        # '';
      };
    })
    (vim_configurable.customize {
      name = "mvim";
      vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # colorschemes
            gruvbox
            base16-vim
            #fzfWrapper # TODO ask upstream
          ] ++ map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: pluginRule.startup or false) pluginRules);
          opt = map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: !(pluginRule.startup or false)) pluginRules);
      };
    })
  ];
}
