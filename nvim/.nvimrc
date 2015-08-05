" vim: nowrap foldmethod=marker foldlevel=2

" Plugins {{{1
"
" Vim-Plug Boilderplate {{{3
" Automatically install vim-plug if it isn't installed
if has('nvim')
	let g:vimdir = '~/.nvim'
else
	let g:vimdir = '~/.vim'
endif
if empty(glob(vimdir.'/autoload/plug.vim'))
	silent !mkdir -p vimdir.'/autoload'
	silent !curl -fLo vimdir.'/autoload/plug.vim'
	    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall
endif

" Installed Plugins {{{2
" Filetypes {{{3
call plug#begin(vimdir.'/plugged')
Plug 'vim-pandoc/vim-pandoc'                              " Pandoc
Plug 'vim-pandoc/vim-pandoc-syntax'                       " Pandoc syntax
Plug 'dogrover/vim-pentadactyl', { 'for': 'pentadactyl' } " Pentadactyl
Plug 'rust-lang/rust.vim', { 'for': 'rust' }              " Rust
if executable('cargo')
	Plug 'phildawes/racer', {'do': 'cargo build --release'}   " Rust Auto-Complete-er
endif
Plug 'klen/python-mode', { 'for': 'python' }              " Advanced python features
" Colorschemes {{{3
Plug 'morhetz/gruvbox'                                    " Gruvbox
Plug 'chriskempson/base16-vim'                            " Base16
Plug 'altercation/vim-colors-solarized'                   " Solarized
" Misc {{{3
" Useable german spell checking (Donaudampfschifffahrtskapitänskajütentür should be accepted)
Plug 'ganwell/vim-hunspell-dicts', {'do': 'curl -fLo '.vimdir.'/spell/hun-de-DE.utf-8.spl http://1042.ch/spell/hun-de-DE.utf-8.spl'}
Plug 'danro/rename.vim'                                   " Rename the current file
Plug 'dhruvasagar/vim-table-mode'                         " Table mode
Plug 'godlygeek/csapprox'                                 " Make colorschemes work in terminal
Plug 'farseer90718/vim-taskwarrior', { 'on': 'TW' }       " Taskwarrior
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'}      " File explorer
Plug 'tpope/vim-repeat'                                   " Make custom options repeatable
Plug 'tpope/vim-fugitive'                                 " Git wrapper
Plug 'tpope/vim-surround'                                 " Surrounding things
Plug 'clever-f.vim'                                       " Make F and T repeatable
Plug 'Valloric/YouCompleteMe', {'do': './install.sh'}     " Better autocompletion
Plug 'scrooloose/syntastic'                               " Syntax checking on save
Plug 'bling/vim-airline'                                  " Better statusbar
Plug 'kien/ctrlp.vim'                                     " Fuzzy file-search
Plug 'bruno-/vim-man'                                     " View manpages in vim
Plug 'godlygeek/tabular', { 'on': 'Tabularize' }          " Alignment
Plug '907th/vim-auto-save'                                " Autosave files
Plug 'vimwiki/vimwiki'                                    " Vimwiki
let g:auto_save = 1
let g:auto_save_no_updatetime = 1
let g:auto_save_in_insert_mode = 0
"let g:auto_save_postsave_hook ='Command'
if exists(':terminal')
	Plug 'kassio/neoterm', { 'on': 'T' }                  " Execute commands in neovims terminal
endif
call plug#end()

" Plugin specific {{{2
" vim-taskwarrior {{{3
let g:task_rc_override = 'rc.defaultwidth=999 rc.defaultheight=0'
let g:task_report_command = ['dsheet', 'today', 'lstoday']
let g:task_report_name = 'lstoday'
let g:task_highlight_field = 1
let g:task_default_prompt = ['due', 'description']
augroup TaskwarriorMapping
	autocmd!
	autocmd FileType taskreport call MapTaskwarrior()
augroup END

function! MapTaskwarrior()
	nmap <buffer> <Space> <Leader>
	nmap <buffer> l <Plug>(taskwarrior_skip_right)
	nmap <buffer> h <Plug>(taskwarrior_skip_left)
	nmap <buffer> t <Plug>(taskwarrior_command)mod<Space>due:tomorrow<CR>
	nmap <buffer> + <Plug>(taskwarrior_start_task)<Plug>(taskwarrior_refresh)
	nmap <buffer> <Leader>d <Plug>(taskwarrior_command)done<CR>
	nmap <buffer> <Leader>a :TW<Space>add<Space>
endfunction

function! Vimtodo()
	set laststatus=0
	set nolist
	set cmdheight=1
	set colorcolumn=0
	TW lstoday
	autocmd vimrc CursorHold task* call Timer()
endfunction

function! Timer()
  call taskwarrior#list()
  set updatetime=5000
  call feedkeys("f\e") " Retrigger the CursorHold event
endfunction

" racer {{{3
let $RUST_SRC_PATH=$HOME."/.local/share/racer/rust/"

" indent guides {{{3
let g:indent_guides_enable_on_vim_startup = 1

" NERDTree {{{3
nnoremap <leader>nt :NERDTreeToggle<cr>

" neoterm {{{3
nnoremap <silent> <leader>r :update<Cr>:T<Space>clear;<Space>cargo<Space>run<Cr>
let g:neoterm_size = 15

" table-mode {{{3
let g:table_mode_corner_corner='+'
let g:table_mode_header_fillchar='='

" Syntastic {{{3
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_python_checkers = ['flake8']

" Vimwiki {{{3
let g:vimwiki_list = [{'path': '~/vimwiki/', 
                     \ 'syntax': 'markdown', 'ext': '.md'}]
" General {{{1
" Settings {{{2
" Misc {{{3
filetype plugin indent on
if &compatible | set nocompatible | endif
set history=5000
set number
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
set shiftwidth=0                       " Shiftwidth equals tabstop
set wrap
set linebreak
set textwidth=80
set colorcolumn=80
set showmatch
set ignorecase
set smartcase
set directory-=.
set backupdir-=.
set mouse+=a
set copyindent                         " Keep spaces used for alignment
set preserveindent
" Remember undos {{{3
if has('persistent_undo')
	set undofile
	set undodir=~/tmp/vim/undo//
	set undolevels=100000
	set undoreload=100000
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

" Appearance {{{3
set list
set listchars=tab:▸\ ,eol:¬,trail:␣
color gruvbox
set background=dark
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

" Mappings {{{2
" Use space as leader {{{3
map <Space> <leader>

" [ ] are hard to reach on a German keyboard
nnoremap ö [
nnoremap ä ]

" make <C-p> and <C-n> behave like up and down (with history filtering)
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" make C-u in insert mode undoable
inoremap <C-U> <C-G>u<C-U>

" Resource vimrc
nnoremap <silent> <Leader>rs :source $MYVIMRC<CR>

" Save {{{3
nnoremap <silent> <Leader>w :write<CR>

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
nnoremap <leader>z :let @z = expand("<cword>")<cr>q:i%s/\C\v<<esc>"zpa>//g<esc>hi

" Insert new line and leave insert mode {{{3
nnoremap <leader>o o<ESC>
nnoremap <leader>O O<ESC>

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


" Use cargo for rust files {{{3
autocmd BufRead,BufNewFile *.rs compiler cargo

" Run tests on every write for rust source files
autocmd BufWritePost *.rs call CargoTest()

function! CargoTest()
	let currentDir = expand('%:p:h')
	let command = '(cd '.currentDir.';clear;cargo test)'
	execute 'T ' command
endfun

" Autosave {{{3
"autocmd BufRead,BufNewFile * call InitializeAutosave()
"function! InitializeAutosave()
"	" Save only regular buffers (e.g. no quickfix)
"	if &buftype == ''
"		autocmd InsertLeave <buffer> nested call AutoSave()
"		autocmd TextChanged <buffer> nested call AutoSave()
"		autocmd CursorHold  <buffer> nested call AutoSave()
"	endif
"endfun
"function! AutoSave()
"	" Save only if the buffer corresponds to a file
"	if expand('%') != ''
"		update
"	endif
"endfun

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

" Source the vimrc file after saving it {{{3
"autocmd vimrc bufwritepost $MYVIMRC source $MYVIMRC

" Commands {{{2
" Delete buffer but keep window {{{3
command! Bd setlocal bufhidden=delete | bnext

" Automatically preview pandoc files {{{3
command! -nargs=? PanPreview call PanPreview()
function! PanPreview()
	let tmpfile=system('mktemp --suffix=.pdf')
	let tmpfile=strpart(tmpfile, 0, len(tmpfile) - 1) " Strip trailing <CR>

	let pandoccmd='pandoc --template=informatik --to=latex ' . shellescape(expand('%:p'), 1) . ' --output ' . shellescape(tmpfile, 1)
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
