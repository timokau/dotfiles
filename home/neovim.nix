{ config, pkgs, lib, ... }:
let
  cfg = config.neovim;
in
with lib;
{
  options.neovim = {
    # enable = mkEnableOption "Neovim terminal";
    python3 = mkOption {
      type = types.package;
      default = pkgs.python3;
      description = "Python3 to use";
    };
  };

  config = 
let
  escapedVimString = str: "'${replaceStrings ["'"] ["''"] str}'";
  stringListToVim = list: "[" + (concatStringsSep "," (map escapedVimString list)) + "]";
  wrapfiller = pkgs.vimUtils.buildVimPluginFrom2Nix {
    name = "wrapfiller";
    src = pkgs.fetchFromGitHub {
      owner = "rickhowe";
      repo = "wrapfiller";
      rev = "7fa1efc70b64d957bc5be1587210b00423c38ebf";
      hash = "sha256-GqmMgSFTE4HGq39Rr+2+NcAs7Tpap5AD7fxUaPAK+KY=";
    };
  };
  pluginRules = let
  in with pkgs.vimPlugins; [
    # {
    #   p = vim-slime;
    #   atStartup = "autocmd PlugAutoload Filetype python :packadd vim-slime";
    #   startup = true;
    #   # slime_target has to be set postLoad, otherwise it will be overwritten
    #   postLoad = ''
    #     let $PATH .= ':${pkgs.python3}/bin'
    #     let g:slime_target = "neovim"
    #     let g:slime_python_ipython = 1
    #   '';
    # }
    {
      p = wrapfiller;
      # https://github.com/rickhowe/wrapfiller
      startup = true;
      preLoad = ''
        let g:WrapFiller = 0 " Disable by default, as it often hangs vim on resize
      '';
    }
    {
      # TODO instead supply a set of packageConfiguration snippets that depend
      # on a set of packages each (to make it possible to depend on lspconfig
      # and ncm2 here)
      p = nvim-lspconfig;
      startup = true;
      # TODO look into pyls-mypy, pyls-black, pyls-isort
      postLoad = ''
        nnoremap <silent> gd          <cmd>lua vim.lsp.buf.definition()<CR>
        nnoremap <silent> K           <cmd>lua vim.lsp.buf.hover()<CR>
        nnoremap <silent> gi          <cmd>lua vim.lsp.buf.implementation()<CR>
        nnoremap <silent> gr          <cmd>lua vim.lsp.buf.references()<CR>
        nnoremap <silent> gs          <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
        nnoremap <silent> <leader>rn  <cmd>lua vim.lsp.buf.rename()<CR>
        nnoremap <silent> <leader>gf  <cmd>lua vim.lsp.buf.formatting()<CR>
        nnoremap <silent> <leader>ca  <cmd>lua vim.lsp.buf.code_action()<CR>

        lua << EOF
          local lspconfig = require('lspconfig')
          local completion = require('completion')

          local on_attach_setup = function(client, bufnr)
            --completion.on_attach()
            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
              vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = {
                  prefix = '',
                },
              }
            )

            -- Adapted from [1].
            -- [1] https://github.com/neovim/nvim-lspconfig/blob/32843975789ad52b10eb27e4fba2d0043aa276fa/README.md#keybindings-and-completion
            local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
            local opts = { noremap = true, silent = true }
            buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
            buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
            buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
            buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
            buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
            buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
            buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
          end

          lspconfig.pylsp.setup{
            cmd = { "${pkgs.python3.pkgs.python-lsp-server}/bin/pylsp" },
            settings = {
              pylsp = {
                plugins = {
                  pycodestyle = {
                    maxLineLength = 88, -- As used by Black
                  },
                }
              },
            },
            on_attach = on_attach_setup,
          }
          lspconfig.texlab.setup{
            cmd = { "${pkgs.texlab}/bin/texlab" },
            on_attach = on_attach_setup,
          }
        EOF
          "local ncm2 = require('ncm2')
            "on_init = ncm2.register_lsp_source
        "set omnifunc=v:lua.vim.lsp.omnifunc
        autocmd FileType tex setlocal omnifunc=v:lua.vim.lsp.omnifunc " instead of vimtex
        " Needed if you want to set your own gutter signs
        call sign_define("LspDiagnosticsErrorSign", {"text" : "✘", "texthl" : "LspGutterError"})
        call sign_define("LspDiagnosticsWarningSign", {"text" : "", "texthl" : "LspGutterWarning"})
        " Set completeopt to have a better completion experience
        set completeopt=menuone,noinsert,noselect
        " Avoid showing message extra message when using completion
        set shortmess+=c

        " always show signcolumns
        set signcolumn=yes
      '';
    }
    {
      p = direnv-vim;
      startup = true;
    }
    {
      p = copilot-vim;
      startup = true;
      preLoad = ''
        let g:copilot_node_command = "${pkgs.nodejs}/bin/node"
        imap <silent><script><expr> <C-e> copilot#Accept("")
        let g:copilot_no_tab_map = v:true
        let g:copilot_filetypes = {
              \ '*': v:false,
              \ 'python': v:true,
              \ 'mail': v:true,
              \ }
      '';
    }
    {
      p = vim-pandoc;
      # TODO also on explicit filetype switch
      atStartup = "autocmd PlugAutoload BufReadPre,BufNewFile *.md,*.pdc :packadd vim-pandoc";
      startup = true;
    }
    {
      p = vim-pandoc-syntax;
      startup = true;
      atStartup = "autocmd PlugAutoload BufReadPre,BufNewFile *.md,*.pdc :packadd vim-pandoc-syntac";
      preLoad = ''
        " Continue pandoc enumerations when hitting return in insert mode
        autocmd FileType pandoc call Pandocsettings()

        function! Pandocsettings()
          setlocal comments +=:-
          setlocal formatoptions +=r
          setlocal colorcolumn=0
        endfun
      '';
    }
    {
      p = vimtex;
      startup = true;
      # atStartup = "autocmd PlugAutoload FileType tex :packadd vimtex";
      # TODO fix preLoad
      atStartup = ''
        let g:tex_flavor = "latex" " work on plain tex files
        let g:vimtex_enable=1
        let g:vimtex_view_method="zathura"
        let g:vimtex_indent_on_ampersands=0
        let g:vimtex_indent_on_ampersands=0
        let g:vimtex_quickfix_open_on_warning=0

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

          syntax region texDot
            \ start="\\begin{dot2tex}"rs=s
            \ end="\\end{dot2tex}\|%stopzone\>"re=e
            \ keepend
            \ contains=texBeginEnd,@NoSpell

          syntax match texStatement '\\setcounter' nextgroup=texNoSpellBraces
          syntax match texStatement '\\newcounter' nextgroup=texNoSpellBraces
          syntax match texStatement '\\value' nextgroup=texNoSpellBraces
          syntax match texStatement '\\ac' nextgroup=texNoSpellBraces
          syntax match texStatement '\\acp' nextgroup=texNoSpellBraces
          syntax region texNoSpellBraces matchgroup=Delimiter start='{' end='}' contained contains=@NoSpell
        endfun
        autocmd BufRead,BufNewFile *.tex :call TexNoSpell()
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
        let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
        " no default mappings please
        let g:vimwiki_map_prefix = '<Leader><Leader>w'
      '';
      postLoad = ''
        nnoremap <silent> <leader>zw <Plug>VimwikiIndex
        nnoremap <silent> <leader>zt <Plug>VimwikiTabIndex
        nnoremap <silent> <leader>zs <Plug>VimwikiUISelect
        nnoremap <silent> <leader>zi <Plug>VimwikiDiaryIndex
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
    # autocompletion, for now replaced bei neovim-lsp
    # {
    #   p = ncm2;
    #   startup = true;
    #   postLoad = ''
    #     " enable ncm2 for all buffers
    #     autocmd BufEnter * call ncm2#enable_for_buffer()

    #     " Ncm2 needs noinsert in completeopt
    #     au User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect
    #     au User Ncm2PopupClose set completeopt=menuone

    #     " don't show ins-completeion-menu messages like "Pattern not found"
    #     set shortmess+=c

    #     " latex support, also requires vimtex
    #     " :help vimtex-complete-ncm2, more advanced at https://github.com/ncm2/ncm2/pull/23
    #     autocmd Filetype tex if exists ('g:vimtex#re#ncm2') | call ncm2#register_source({
    #             \ 'name': 'vimtex',
    #             \ 'priority': 8,
    #             \ 'scope': ['tex'],
    #             \ 'mark': 'tex',
    #             \ 'word_pattern': '\w+',
    #             \ 'complete_pattern': g:vimtex#re#ncm2,
    #             \ 'on_complete': ['ncm2#on_complete#omni', 'vimtex#complete#omnifunc'],
    #             \ }) | endif
    #   '';
    # }
    # {
    #   # autocomplete paths
    #   p = ncm2-ultisnips;
    #   startup = true;
    # }
    # {
    #   # autocomplete paths
    #   p = neosnippet;
    #   atStartup = ''
    #     imap <C-j>     <Plug>(neosnippet_expand_or_jump)
    #     smap <C-j>     <Plug>(neosnippet_expand_or_jump)
    #     xmap <C-j>     <Plug>(neosnippet_expand_target)
    #     let g:neosnippet#snippets_directory = '/home/timo/snippets'
    #   '';
    #   startup = true;
    # }
    # {
    #   # autocomplete paths
    #   p = neosnippet-snippets;
    #   startup = true;
    # }
    # {
    #   # autocomplete paths
    #   p = ncm2-path;
    #   startup = true;
    # }
    # {
    #   # autocompletion
    #   p = ncm2-jedi;
    #   atStartup = "autocmd PlugAutoload FileType python :packadd ncm2-jedi";
    # }
    {
      # linting
      startup = true;
      p = neomake;
      postLoad = let
        pylintArgs = [
          "--good-names=x,y"
          "--include-naming-hint=y" # show the regex that failed to match on "bad" names
          "--module-rgx=.*" # https://github.com/neomake/neomake/issues/2278

          # Apparently one should use `if seq:` instead of `if len(seq) != 0`.
          # I disagree.
          "--disable=len-as-condition" 
        ];
      in
      # TODO how does pylint find its libs
      ''
        let $PATH .= ':${cfg.python3}/bin:${cfg.python3.pkgs.pylint}/bin'
        let g:neomake_python_enabled_makers = ['python']
        let g:neomake_tex_enabled_makers = ['chktex'] " no lacheck
        let g:neomake_sty_enabled_makers = ['chktex'] " no lacheck
        " see https://github.com/neomake/neomake/pull/1788/files for usage
        let g:neomake_tempfile_dir = '/tmp/neomake-tempfiles%:p:h'

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
        " until https://github.com/neomake/neomake/pull/2161 is merged
        let g:neomake_python_python_exe = 'python3'
        let g:neomake_python_pylint_args = neomake#makers#ft#python#pylint().args + ${stringListToVim pylintArgs}
      '';
    }
    {
      p = fzf-vim;
      startup = true;
      preLoad = ''
        " Ignore non-text filetypes / generated files
        let fzf_ignores = ""
        "for ign in ['class', 'pdf', 'fdb_latexmk', 'aux', 'fls', 'synctex.gz', 'nav', 'snm', 'zip']
          "let fzf_ignores = fzf_ignores . " --ignore='*." . ign . "'"
        "endfor

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
    {
      p = completion-nvim;
      startup = true;
      postLoad = ''
        " Use completion-nvim in every buffer
        " autocmd BufEnter * lua require'completion'.on_attach()

        " Use <Tab> and <S-Tab> to navigate through popup menu
        inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

        " Set completeopt to have a better completion experience
        set completeopt=menuone,noinsert,noselect

        " Avoid showing message extra message when using completion
        set shortmess+=c

        " map <c-p> to manually trigger completion
        inoremap <silent><expr> <c-p> completion#trigger_completion()

        " Use <Tab> as a trigger key
        "function! s:check_back_space() abort
        "    let col = col('.') - 1
        "    return !col || getline('.')[col - 1]  =~ '\s'
        "endfunction

        "inoremap <silent><expr> <TAB>
        "  \ pumvisible() ? "\<C-n>" :
        "  \ <SID>check_back_space() ? "\<TAB>" :
        "  \ completion#trigger_completion()

        " TODO look into snippet support
        " https://github.com/haorenW1025/completion-nvim#enable-snippets-support
        " Automatically fall back to other completion providers
        let g:completion_auto_change_source = 1
      '';
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
    preLoadFile = singleSourceFile "pre-load-${pname}.vim" pluginRule.preLoad;
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
    postLoadFile = singleSourceFile "post-load-${pname}.vim" pluginRule.postLoad;
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

  mynvim = (pkgs.wrapNeovim pkgs.neovim-unwrapped {
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # colorschemes
            base16-vim
          ] ++ map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: pluginRule.startup or false) pluginRules);
          opt = map (pluginRule: pluginRule.p) (pkgs.lib.filter (pluginRule: !(pluginRule.startup or false)) pluginRules);
        };
        customRC = pluginRc + builtins.replaceStrings [
          "'rustup'"
          "'/usr/bin/env black'"
          "'/usr/bin/env pandoc'"
          "'/usr/bin/env xdg-open'"
        ] [
          "'${pkgs.rustup}/bin/rustup'"
          "'${pkgs.python3.pkgs.black}/bin/black'"
          "'${pkgs.pandoc}/bin/pandoc'"
          "'${pkgs.xdg-utils}/bin/xdg-open'"
        ] (builtins.readFile ../nvim/.config/nvim/init.vim);
      };
    });
in
{
  home.packages = with pkgs; [
    mynvim
    (neovim-qt.override { neovim = mynvim; })
  ];
};
}
