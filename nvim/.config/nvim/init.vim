" vim: foldmethod=marker foldlevel=2

augroup git-commit
	autocmd!
	autocmd Filetype gitcommit setlocal textwidth=72 | setlocal wrap
	" Highlight chars in the 51st column in the subject
	highlight SubjectTooLong ctermbg=Red ctermfg=White
	call matchaddpos('SubjectTooLong', [[3, 51]], 100)
augroup END

" latex spelling
autocmd BufRead,BufNewFile *.tex setlocal spell | setlocal spelllang=en

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
set hidden
set autoindent
set backspace=indent,eol,start
set hlsearch
set wildignore+=*~,*.pyc,*.swp,*.class,*.pdf,*.aux,*.fdb_latexmk,*.dfls,*.toc,*.synctex.gz,*.fls,*.nav,*.snm
set tabstop=4
set shiftwidth=4 " Shiftwidth equals tabstop
set wrap
set linebreak
set breakindent
" Indicate wraps
set breakindentopt=sbr
set showbreak=↪
set textwidth=80
set showmatch
set ignorecase
set smartcase
set directory-=.
set backupdir-=.
set nobackup

" Highlight chars in the 81st column
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)

if has('nvim')
	set inccommand=split
endif
set mouse+=a
set copyindent " Keep spaces used for alignment
set preserveindent

" Diffs {{{3
set diffopt=filler,vertical

" Remember undos {{{3
set undolevels=100000
set undoreload=100000
set undofile
if !has("nvim")
	" nvim has sensible defaults, but vim defaults to just dumping it into the
	" working directory
	silent call system('mkdir -p $HOME/.local/share/vim/undo')
	set undodir=$HOME/.local/share/vim/undo
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

" Don't keep undo files for files in temp directories or shm
" For exmple when using `sudoedit` this is important.
augroup undoskip
	autocmd!
	silent! autocmd BufWritePre
	              \ */tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*
	              \ setlocal noundofile | setlocal viminfo=
augroup END

" Helper functions {{{3
" Execute macro over visual selection {{{3
" https://github.com/stoeffel/.dotfiles/blob/master/vim/visual-at.vim
xnoremap @ :<C-u>call ExecuteMacroOverVisualRange()<CR>

function! ExecuteMacroOverVisualRange()
	echo "@".getcmdline()
	execute ":'<,'>normal @".nr2char(getchar())
endfunction

" Appearance {{{3
set list
set listchars=tab:▸\ ,eol:¬,trail:␣
set background=dark
set guifont=Source\ Code\ Pro\ 11

" Colorscheme (if available)
let g:gruvbox_italic = 1 " Use italic
let g:gruvbox_contrast_dark = "hard" " Hard contrast
silent! colorscheme gruvbox
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

" Email-Settings {{{3
autocmd FileType mail execute 'normal G' | set spell | set spelllang=de

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

" Location List
nnoremap <silent> <Leader>e :lopen<CR>
nnoremap <silent> <Leader>E :copen<CR>
nnoremap <silent> <Leader>ln :lprevious<CR>
nnoremap <silent> <Leader>lp :lnext<CR>
nnoremap <silent> <Leader>cn :cnext<CR>
nnoremap <silent> <Leader>cp :cprevious<CR>

" search for TODO comments {{{3
nnoremap <Leader>t :silent grep TODO<CR>

" make C-u in insert mode undoable
inoremap <C-U> <C-G>u<C-U>

" Save {{{3
nnoremap <silent> <Leader>w :write<CR>

" Visual star search
xnoremap * :<C-u> call <SID>VSetSearch()<CR>/<C-R>=@/<CR><CR>
xnoremap # :<C-u> call <SID>VSetSearch()<CR>?<C-R>=@/<CR><CR>

" search/replace the word under the cursor
xnoremap <leader>s :<C-u> call <SID>VSetSearch()<CR>:%s /<C-R>=@/<CR>/

function! s:VSetSearch()
	let temp = @s
	norm! gv"sy
	let @/ = '\V' . substitute(escape(@s, '/\'), '\n', '\\n', 'g')
	let @s = temp
endfunction

" Make Y consistent with other commands
nnoremap Y y$

" Command-line navigation (no arrow keys) {{{3
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>
cnoremap <C-S-h> <S-Left>
cnoremap <C-S-l> <S-Right>

" Expand %% to the folder of the currently edited file {{{3
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" Resize {{{3
nnoremap <silent> <Leader>- :resize -3<CR>
nnoremap <silent> <Leader>+ :resize +3<CR>
nnoremap <silent> <Leader>< :vertical resize -3<CR>
nnoremap <silent> <Leader>> :vertical resize +3<CR>

" Spellchecking {{{3
nnoremap <silent> <leader>sd :set spell spelllang=de_20<CR>
nnoremap <silent> <leader>se :set spell spelllang=en_us<CR>

" Stop highlighting the last search {{{3
nnoremap <silent> <leader>c :nohlsearch<CR>

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

" Tab in insert mode idents
inoremap <Tab> <C-t>

" Terminal mode {{{3
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

" Autocommands {{{2
" Initialize (reset) autocommands {{{3
augroup vimrc
	autocmd!
augroup END

" Don't list location-list / quickfix windows {{{3
augroup nonEditableBuffers
	autocmd!
	" Don't list location-list / quickfix windows
	" (since I don't want to switch with them with :bnext & co)
	" Also, close them with q
	autocmd BufWinEnter * if &buftype == 'quickfix'
			\| setlocal nobuflisted
			\| nnoremap <silent> <buffer> q :bd<CR>
		\| endif
augroup END

" SML comments {{{3
autocmd vimrc FileType sml setlocal commentstring=(*%s*)

" Use vim help instead of man in vim files when K is pressed {{{3
autocmd vimrc FileType vim setlocal keywordprg=:help

" Transparent editing of gpg encrypted files {{{3
" By Wouter Hanegraaff
augroup encrypted
	autocmd!
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
cmap w!! w !sudo tee % > /dev/null

" open video
nmap <leader>m yiW:silent !video-stream '<C-r>0' >/dev/null 2>&1 &<CR>A watched<ESC>

set termguicolors " true color
