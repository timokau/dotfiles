" vim: nowrap foldmethod=marker foldlevel=2

" Plugins {{{1

" Vim-Plug Boilderplate {{{3
" Automatically install vim-plug if it isn't installed
if has('nvim')
	let g:vimdir = $HOME . '/.config/nvim'
	let g:spelldir = $HOME . '/.local/share/nvim/site/spell'
else
	let g:vimdir = $HOME . '/.vim'
	let g:spelldir = g:vimdir . '/spell'
endif

if has("gui_running")
	set guioptions = 'c'
	set guifont=Terminus 12
endif

if empty(glob(vimdir.'/autoload/plug.vim'))
	execute "!curl -fLo " . shellescape(vimdir . "/autoload/plug.vim") . " --create-dirs " .
	      \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
	autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Installed Plugins {{{2
" Filetypes {{{3
call plug#begin(vimdir.'/plugged')
Plug 'vim-pandoc/vim-pandoc'                              " Pandoc
Plug 'vim-pandoc/vim-pandoc-syntax'                       " Pandoc syntax
Plug 'lervag/vimtex'                                      " Latex support
Plug 'dogrover/vim-pentadactyl', { 'for': 'pentadactyl' } " Pentadactyl
Plug 'rust-lang/rust.vim', { 'for': 'rust' }              " Rust
if executable('cargo')
	Plug 'racer-rust/vim-racer'                           " Rust Auto-Complete-er
endif
Plug 'klen/python-mode', { 'for': 'python' }              " Advanced python features
" Colorschemes {{{3
Plug 'morhetz/gruvbox'                                    " Gruvbox
Plug 'chriskempson/base16-vim'                            " Base16
" Misc {{{3
" Useable german spell checking (Donaudampfschifffahrtskapitänskajütentür should be accepted)
Plug 'ganwell/vim-hunspell-dicts', {'do': 'curl -fLo ' . spelldir .'/hun-de-DE.utf-8.spl http://1042.ch/spell/hun-de-DE.utf-8.spl'}
Plug 'godlygeek/csapprox'                                 " Make colorschemes work in terminal
if executable('zeal')
	Plug 'KabbAmine/zeavim.vim'                           " Offline documentation
endif
Plug 'tpope/vim-repeat'                                   " Make custom options repeatable
Plug 'tpope/vim-fugitive'                                 " Git wrapper
Plug 'tpope/vim-surround'                                 " Surrounding things
Plug 'tpope/vim-unimpaired'                               " Mappings
Plug 'tpope/vim-commentary'                               " Comment stuff out
Plug 'clever-f.vim'                                       " Make F and T repeatable
"
if has('nvim')
	Plug 'Shougo/deoplete.nvim'                           " Better autocompletion
else
	Plug 'Valloric/YouCompleteMe', {'do': './install.sh'} " Better autocompletion
endif
Plug 'SirVer/ultisnips'                                   " Snipptes suppert
Plug 'scrooloose/syntastic'                               " Syntax checking on save
Plug 'bling/vim-airline'                                  " Better statusbar
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }          " Alignment
Plug 'vimwiki/vimwiki'                                    " Vimwiki
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
if exists(':terminal')
	Plug 'kassio/neoterm'                                 " Execute commands in neovims terminal
endif
call plug#end()

" Plugin specific {{{2
" vim-ariline {{{3
let g:airline#extensions#whitespace#mixed_indent_algo = 2

" racer {{{3
let $RUST_SRC_PATH=$HOME . "/.local/share/racer/rust/src"
silent execute "!mkdir -p " . shellescape($RUST_SRC_PATH)
let g:racer_cmd = '/usr/bin/racer'

" rust.vim {{{3
let g:rustfmt_autosave = 1 " Run rustfmt on save

" vimtex {{{3
" augroup vimtex_config
" 	autocmd!
" 	autocmd FileType tex autocmd BufWritePost <buffer> VimtexView
" 	autocmd User VimtexEventQuit call vimtex#latexmk#clean(0)
" augroup END
let g:vimtex_view_method="zathura"

" deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#enable_fuzzy_completion = 1
let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})

" neoterm {{{3
nnoremap <silent> <leader>r :update<Cr>:T<Space>clear;<Space>cargo<Space>run<Cr>
let g:neoterm_size = 15

" surround {{{3
" surround with latex command
let g:surround_{char2nr('c')} = "\\\1command\1{\r}"

" Syntastic {{{3
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_tex_chktex_quiet_messages = {
	\ "regex": ['Vertical rules in tables are ugly.',
	          \ 'You should put a space in front of parenthesis.',
	          \ 'You should put a space after parenthesis.',
	          \ 'Command terminated with space.',
	          \ 'You might wish to put this between a pair of `{}''',
	          \ 'You should avoid spaces after parenthesis.',
	          \ 'Number of `('' doesn''t match the number of `)''!',
	          \ 'Mathmode still on at end of LaTeX file.',
	          \ 'Delete this space to maintain correct pagereferences.',
	          \ 'Intersentence spacing (`\\@'') should perhaps be used.',
	          \ 'You should use \\.\?dots to achieve an ellipsis.',
	          \ 'Wrong length of dash may have been used.']
\}

" Ultisnips {{{3
" Trigger configuration. <tab> interferes with YouCompleteMe
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetsDir=vimdir . "/UltiSnips"
let g:UltiSnipsEnableSnipMate=0

" Vimwiki {{{3
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
" no default mappings please
nnoremap <silent> <leader>zw <Plug>VimwikiIndex
nnoremap <silent> <leader>zt <Plug>VimwikiTabIndex
nnoremap <silent> <leader>zs <Plug>VimwikiUISelect
nnoremap <silent> <leader>zi <Plug>VimwikiDiaryIndex

" fzf {{{3
let g:fzf_nvim_statusline = 0 " disable statusline overwriting

nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>a :Buffers<CR>
nnoremap <silent> <leader>; :BLines<CR>
nnoremap <silent> <leader>. :Lines<CR>
nnoremap <silent> <leader>o :BTags<CR>
nnoremap <silent> <leader>O :Tags<CR>
nnoremap <silent> <leader>: :Commands<CR>
nnoremap <silent> <leader>? :History<CR>
nnoremap <silent> <leader>/ :execute 'Ag ' . input('Ag/')<CR>
nnoremap <silent> <leader>K :call SearchWordWithAg()<CR>
vnoremap <silent> <leader>K :call SearchVisualSelectionWithAg()<CR>
nnoremap <silent> <leader>gl :Commits<CR>
nnoremap <silent> <leader>ga :BCommits<CR>

imap <C-x><C-f> <plug>(fzf-complete-file-ag)
imap <C-x><C-l> <plug>(fzf-complete-line)

function! SearchWordWithAg()
execute 'Ag' expand('<cword>')
endfunction

function! SearchVisualSelectionWithAg() range
	let old_reg = getreg('"')
	let old_regtype = getregtype('"')
	let old_clipboard = &clipboard
	set clipboard&
	normal! ""gvy
	let selection = getreg('"')
	call setreg('"', old_reg, old_regtype)
	let &clipboard = old_clipboard
	execute 'Ag' selection
endfunction

" General {{{1
" Settings {{{2
" Misc {{{3
filetype plugin indent on
if &compatible | set nocompatible | endif
set history=5000
set number
set relativenumber
set cursorline
set ruler
set cmdheight=2
set splitright
set splitbelow
set nofoldenable
set hidden
set autoindent
set backspace=indent,eol,start
set hlsearch
set wildignore+=*~,*.pyc,*.swp
set tabstop=4
set shiftwidth=4                       " Shiftwidth equals tabstop
set wrap
if has('linebreak')
	set linebreak
	set breakindent
endif
set textwidth=99
set colorcolumn=+0
set showmatch
set ignorecase
set smartcase
set directory-=.
set backupdir-=.
set nobackup
if has('nvim')
	silent execute "!mkdir -p " . &backupdir
endif
set mouse+=a
set copyindent                         " Keep spaces used for alignment
set preserveindent
" Remember undos {{{3
if has('persistent_undo')
	silent call system('mkdir -p $HOME/tmp/vim/undo')
	if !has("nvim")
		set undodir=$HOME/tmp/vim/undo
	endif
	set undolevels=100000
	set undoreload=100000
	set undofile
endif

" Prevent Vim from keeping the contents of tmp files on the system {{{3
" Don't backup files in temp directories or shm
if exists('&backupskip')
set backupskip+=/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*
endif

" Don't keep swap files in temp directories or shm
if has('autocmd')
augroup swapskip
	autocmd!
	silent! autocmd BufNewFile,BufReadPre
	              \ /tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*
	              \ setlocal noswapfile
augroup END
endif

" Don't keep undo files in temp directories or shm
if has('persistent_undo') && has('autocmd')
augroup undoskip
	autocmd!
	silent! autocmd BufWritePre
	              \ /tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*
	              \ setlocal noundofile
augroup END
endif

" Don't keep viminfo for files in temp directories or shm
if has('viminfo')
if has('autocmd')
	augroup viminfoskip
		autocmd!
		silent! autocmd BufNewFile,BufReadPre
		              \ /tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*
		              \ setlocal viminfo=
	augroup END
endif
endif

" Helper functions {{{3
" Check if script is loaded
function! IsLoaded(pattern)
	let scriptnames_output = ''
	redir => scriptnames_output
	silent scriptnames
	redir END

	for line in split(scriptnames_output, "\n")
		" Only do non-blank lines.
		if line =~ '\S'
			" Get the first number in the line.
			let nr = matchstr(line, '\d\+')
			" Get the file name, remove the script number " 123: ".
			let name = substitute(line, '.\+:\s*', '', '')
			" Check against the pattern
			echo name
			if name =~ a:pattern
				return 1
			endif
		endif
	endfor
	unlet scriptnames_output
	return 0
endfun

" Appearance {{{3
if has ("multi_byte_encoding")
	if !has("nvim")
		set encoding=utf-8
	endif
endif
set list
set listchars=tab:▸\ ,eol:¬,trail:␣
set background=dark
" Colorscheme (if available)
silent! color gruvbox
let cur_colorscheme = ''
redir => cur_colorscheme
silent colorscheme
redir END
if !has("gui_running")
	if split(cur_colorscheme, "\n")[0] != 'gruvbox' || &t_Co < 88
		silent! colorscheme darkblue
	endif
endif
syntax enable
" Better highlighting for concealed text
hi Conceal guibg=white guifg=black
" Formating {{{3
set formatoptions-=t                   " Don't autowrap text
set formatoptions-=c                   " Don't autowrap comments
set formatoptions-=o                   " Don't insert comment-leader
let g:netrw_dirhistmax = 0 " Don't save a file history in the .vim folder

" Email-Settings {{{3
autocmd FileType mail execute 'normal G' | set formatoptions-=t

" Use ack/ag if available
if executable ('ag')
	set grepprg=ag\ --nogroup\ --nocolor
elseif executable ('ack')
	set grepprg=ack\ --nogroup\ --nocolor
endif

" Mappings {{{2
" Use space as leader {{{3
map <Space> <leader>

" Quickly use the system keyboard by saving 2 (!) keys {{{3
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" [ ] are hard to reach on a German keyboard {{{3
nnoremap ö [
nnoremap ä ]

" search for TODO comments {{{3
nnoremap <Leader>t :silent grep TODO<CR>

" close {{{3
nnoremap <Leader>q :quit<CR>
nnoremap <Leader>Q :qall<CR>

" make <C-p> and <C-n> behave like up and down (with history filtering)
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" make C-u in insert mode undoable
inoremap <C-U> <C-G>u<C-U>

" Resource vimrc
nnoremap <silent> <Leader>rs :source $MYVIMRC<CR>

" Map ü and + to [ and ] (like they are positioned on the US-Keyboard) {{{3
nmap ü [
nmap + ]
omap ü [
omap + ]
xmap ü [
xmap + ]

" Save {{{3
nnoremap <silent> <Leader>w :write<CR>

" Visual star search
xnoremap * :<C-u> call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u> call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>

function! s:VSetSearch()
	let temp = @s
	norm! gv"sy
	let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
	let @s = temp
endfunction

" Join words {{{3
" Move to the space, delete it, ensure the first letter of the formerly second
" word is lower case
nnoremap <Leader>J Elxgul

" Make Y consistent with other commands
nnoremap Y y$

" I'm feeling lucky correction {{{3
nnoremap z0 1z=
" [s is unreachable on a german keyboard
nnoremap zs [sb
nnoremap zS ]sb

" Command-line navigation (no arrow keys) {{{3
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>
cnoremap <C-S-h> <S-Left>
cnoremap <C-S-l> <S-Right>

" Expand %% to the folder of the currently edited file {{{3
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" Use , for commands {{{3
noremap , :

" Resize {{{3
nnoremap <silent> <Leader>- :resize -3<CR>
nnoremap <silent> <Leader>+ :resize +3<CR>
nnoremap <silent> <Leader>< :vertical resize -3<CR>
nnoremap <silent> <Leader>> :vertical resize +3<CR>

" Move through soft wraps {{{3
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k
nnoremap 0 g^
nnoremap $ g$

" Spellchecking {{{3
nnoremap <silent> <leader>s :set spell!<CR>
nnoremap <silent> <leader>sd :set spell spelllang=de_20<CR>
nnoremap <silent> <leader>sD :set spell spelllang=hun-de-DE<CR>
nnoremap <silent> <leader>se :set spell spelllang=en_us<CR>

" search/replace the word under the cursor {{{3
nnoremap <leader>s :let @z = expand("<cword>")<cr>q:i%s/\C\v<<esc>"zpa>//g<esc>hi

" Stop highlighting the last search {{{3
nnoremap <leader>c :nohlsearch<CR>

" Navigate between split views with <CTRL>-[h/j/k/l]
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Move splits
nnoremap <C-M-h> <C-w>H
nnoremap <C-M-j> <C-w>J
nnoremap <C-M-k> <C-w>K
nnoremap <C-M-l> <C-w>L


" Alignment with tab {{{3
inoremap <S-Tab> <Space><Space><Space><Space>

" Terminal mode {{{3
if exists(':terminal')
	" Leave terminal mode and jump to the last line
	tnoremap <silent> <ESC><ESC> <C-\><C-n>G:call search(".", "b")<CR>$
	" Navigation
	tnoremap <C-h> <C-\><C-n><C-w>h
	tnoremap <C-j> <C-\><C-n><C-w>j
	tnoremap <C-k> <C-\><C-n><C-w>k
	tnoremap <C-l> <C-\><C-n><C-w>l
	nnoremap <leader>vt :vs term://zsh<CR>i
	" Re-run last command
	tnoremap <C-r> <Up><Cr>

	augroup terminal
		autocmd!
		" Don't show listchars in terminals
		" Don't list terminals in the buffer list
		" Delete terminals when no active buffer shows them
		autocmd TermOpen * setlocal nolist nobuflisted bufhidden=delete
		" Enter insert mode when switching to a terminal
		autocmd BufEnter term://* startinsert
	augroup END
endif
"
" Autocommands {{{2
" Initialize (reset) autocommands {{{3
augroup vimrc
	autocmd!
augroup END

" Run tests on every write for rust source files
autocmd BufWritePost *.rs call CargoTest()

function! CargoTest()
	let currentDir = expand('%:p:h')
	let command = '(cd '.currentDir.';clear;cargo test)'
	execute 'T ' command
endfun

" Use vim help instead of man in vim files when K is pressed {{{3
autocmd vimrc FileType vim setlocal keywordprg=:help

" Continue pandoc enumerations when hitting return in insert mode {{{3
autocmd vimrc FileType pandoc call Pandocsettings()

function! Pandocsettings()
	setlocal comments +=:-
	setlocal formatoptions +=r
	setlocal colorcolumn=0
	"setlocal spelllang=de_20
	" Todo: only if plugins enabled
	setlocal spelllang=hun-de-DE
	" Arrows
	iabbrev <buffer> \-> $\rightarrow$
	iabbrev <buffer> \<- $\leftarrow$
	iabbrev <buffer> \<> $\leftrightarrow$
	" Headings
	iabbrev <buffer> 2# ##
	iabbrev <buffer> 3# ###
	iabbrev <buffer> 4# ####<Space>\<Tab>\<Tab>
endfun

" Transparent editing of gpg encrypted files {{{3
" By Wouter Hanegraaff
augroup encrypted
	au!
	" First make sure nothing is written to ~/.viminfo while editing
	" an encrypted file.
	autocmd BufReadPre,FileReadPre *.gpg set viminfo=
	" We don't want a various options which write unencrypted data to disk
	autocmd BufReadPre,FileReadPre *.gpg set noswapfile noundofile nobackup

	" Switch to binary mode to read the encrypted file
	autocmd BufReadPre,FileReadPre *.gpg set bin
	autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
	autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt 2> /dev/null

	" Switch to normal mode for editing
	autocmd BufReadPost,FileReadPost *.gpg set nobin
	autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
	autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

	" Convert all text to encrypted text before writing
	autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
	" Undo the encryption so we are back in the normal text, directly
	" after the file has been written.
	autocmd BufWritePost,FileWritePost *.gpg u
augroup END

" Commands {{{2
" Delete buffer but keep window {{{3
command! Bd setlocal bufhidden=delete | bnext

" Automatically preview pandoc files {{{3
command! -nargs=? PanPreview call PanPreview()
function! PanPreview()
	let tmpfile=system('mktemp --suffix=.pdf')
	let tmpfile=strpart(tmpfile, 0, len(tmpfile) - 1) " Strip trailing <CR>

	let pandoccmd='pandoc --template=nicolin --to=latex ' . shellescape(expand('%:p'), 1) . ' --output ' . shellescape(tmpfile, 1)
	let readercmd='xdg-open ' . shellescape(tmpfile, 1) . ' &'
	execute 'silent !' . pandoccmd . ' && ' .readercmd

	" Reload on save
	augroup panpreview
		autocmd!
	augroup END
	execute 'autocmd panpreview BufWritePost <buffer> silent !' . pandoccmd
endfunction

" Edit a tmp file {{{3
command! -nargs=? TmpFile call TmpFile('<args>')
function! TmpFile(args)
	let args=a:args
	let tmpfile=system('mktemp --suffix=' . args)
	execute "edit ".tmpfile
endfunction

" Save as root {{{3
command! -nargs=? Swrite :w !sudo tee %
