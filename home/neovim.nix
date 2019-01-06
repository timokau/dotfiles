{ pkgs, ... }:
let
  pluginRules = with pkgs.vimPlugins; [
    {
      p = vim-pandoc;
      atStartup = "autocmd PlugAutoload BufReadPre,BufNewFile *.md,*.pdc :packadd vim-pandoc";
    }
    {
      p = vim-pandoc-syntax;
      atStartup = "autocmd PlugAutoload BufReadPre,BufNewFile *.md,*.pdc :packadd vim-pandoc";
      preLoad = ''
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
      atStartup = "autocmd PlugAutoload FileType tex :packadd vimtex";
      preLoad = ''
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
      atStartup = ''
        autocmd PlugAutoload FileType rust :packadd rust-vim
      '';
      preLoad = ''
        " Run rustfmt on save
        let g:rustfmt_command='${pkgs.rustfmt}/bin/rustfmt'
        let g:rustfmt_autosave = 1
      '';
    }
    {
      p = LanguageClient-neovim;
      atStartup = ''
        autocmd PlugAutoload FileType rust :packadd LanguageClient-neovim
      '';
      preLoad = ''
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
      atStartup = ''
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
      preLoad = ''
        " surround with latex command
        let g:surround_{char2nr('c')} = "\\\1command\1{\r}"
      '';
    }
    {
      # make custom actions (like the ones from vim-surround) repeatable (`.`)
      p = vim-repeat;
      startup = true;
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
      preLoad = ''
        autocmd SourcePre ${vimwiki}/share/vim-plugins/vimwiki/plugin/vimwiki.vim let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
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
      preLoad = ''
        " Trigger configuration. <tab> interferes with YouCompleteMe
        let g:UltiSnipsExpandTrigger="<c-j>"
        let g:UltiSnipsJumpForwardTrigger="<c-j>"
        let g:UltiSnipsJumpBackwardTrigger="<c-k>"
        let g:UltiSnipsEditSplit="vertical"
        let g:UltiSnipsSnippetsDir='${../nvim/.config/nvim/UltiSnips}'
        let g:UltiSnipsEnableSnipMate=0
      '';
    }
    {
      # highlight possible motion targets
      p = vim-easymotion;
      startup = true;
      preLoad = ''
        map , <Plug>(easymotion-prefix)
        map ,/ <Plug>(easymotion-sn)
        omap ,/ <Plug>(easymotion-tn)
      '';
    }
    {
      # autocompletion
      p = ncm2;
      startup = true;
      postLoad = ''
        " enable ncm2 for all buffers
        autocmd BufEnter * call ncm2#enable_for_buffer()

        " Ncm2 needs noinsert in completeopt
        au User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect
        au User Ncm2PopupClose set completeopt=menuone

        " don't show ins-completeion-menu messages like "Pattern not found"
        set shortmess+=c

        " latex support, also requires vimtex
        " :help vimtex-complete-ncm2, more advanced at https://github.com/ncm2/ncm2/pull/23
        autocmd Filetype tex if exists ('g:vimtex#re#ncm2') | call ncm2#register_source({
                \ 'name': 'vimtex',
                \ 'priority': 8,
                \ 'scope': ['tex'],
                \ 'mark': 'tex',
                \ 'word_pattern': '\w+',
                \ 'complete_pattern': g:vimtex#re#ncm2,
                \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
                \ }) | endif
      '';
    }
    {
      # autocomplete paths
      p = ncm2-path;
      startup = true;
    }
    {
      # autocompletion
      p = ncm2-jedi;
      atStartup = "autocmd PlugAutoload FileType python :packadd ncm2-jedi";
    }
    {
      # linting
      startup = true;
      p = neomake;
      postLoad = ''
        let $PATH .= ':${pkgs.python3.pkgs.pyflakes}/bin:${pkgs.python3.pkgs.pylint}/bin'
        let g:neomake_python_enabled_makers = ['python', 'pyflakes', 'pylint']
        let g:neomake_tex_enabled_makers = ['chktex'] " no lacheck
        let g:neomake_sty_enabled_makers = ['chktex'] " no lacheck

        " execute 500ms after changes ([n]ormal and [i]nsert), after [r]ead and [w]rite
        call neomake#configure#automake('nrwi', 500)

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
      p = pkgs.symlinkJoin {
        name = "fzf-vim";
        paths = [
          fzf-vim
          fzfWrapper
        ];
      };
      startup = true;
      preLoad = ''
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

  singleSourceFile = name: commands: pkgs.writeTextFile {
      inherit name;
      text = ''
        if exists('s:hasBeenSourced')
          finish
        else
          let s:hasBeenSourced = 1
        endif
        ${commands}
      '';
    };

  preLoadSnippet = pluginRule:
  let
    preLoadFile = singleSourceFile "pre-load-${pname}" pluginRule.preLoad;
    plugin = pluginRule.p;
    pname = plugin.pname or plugin.name;
    preLoadAutocmd = "autocmd PlugAutoload SourcePre ${plugin}/* source ${preLoadFile}";
  in
  if builtins.hasAttr "preLoad" pluginRule then preLoadAutocmd else "";

  postLoadSnippet = pluginRule:
  # late load cannot be reliably detected, depends on
  # https://github.com/vim/vim/issues/3739
  assert builtins.hasAttr "postLoad" pluginRule -> pluginRule.startup;
  let
    postLoadFile = singleSourceFile "post-load-${pname}" pluginRule.postLoad;
    plugin = pluginRule.p;
    pname = plugin.pname or plugin.name;
    # unconditional source, must happen after plugins are loaded
    postLoadCmd = "source ${postLoadFile}";
  in
  if builtins.hasAttr "postLoad" pluginRule then postLoadCmd else "";

  pluginRc = ''
    augroup PlugAutoload
  ''
    + pkgs.lib.concatStringsSep "\n" (map (pluginRule: pluginRule.atStartup or "") pluginRules)
    + pkgs.lib.concatStringsSep "\n" (map preLoadSnippet pluginRules) + ''
    packloadall " load startup packages
  ''
    + pkgs.lib.concatStringsSep "\n" (map postLoadSnippet pluginRules);

  hunspell = pkgs.fetchurl {
    # Donaudampfschifffahrt
    # Donaudampfschifffahrtskapitänskajütentür
    url = "https://1042.ch/spell/hun-de-DE.utf-8.spl";
    sha256 = "1z9b4vw8k0ps1k5yq1bgkzrp7b969brwcciry24rga535xhgkbpx";
  };
  # override default `de` spelllang, this needs to be *pre*pended to runtimepath
  hunspellDir = pkgs.runCommand "hunspell-dir" {} ''
    mkdir -p $out/spell
    cp '${hunspell}' "$out/spell/de.utf-8.spl"
  '';

  mynvim = (pkgs.neovim.override {
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # colorschemes
            gruvbox
            base16-vim
          ] ++ map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: pluginRule.startup or false) pluginRules);
          opt = map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: !(pluginRule.startup or false)) pluginRules);
        };
        customRC = pluginRc + ''
          set runtimepath^=${hunspellDir}
        '' + builtins.replaceStrings [
          "'rustup'"
        ] [
          "'${pkgs.rustup}/bin/rustup'"
        ] (builtins.readFile ../nvim/.config/nvim/init.vim);
      };
    });
in
{
  home.packages = with pkgs; [
    mynvim
    (neovim-qt.override { neovim = mynvim; })
  ];
}
