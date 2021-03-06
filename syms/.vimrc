set shell=/usr/bin/zsh
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-rhubarb'
Plugin 'vim-scripts/L9'
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-rails'
Plugin 'ecomba/vim-ruby-refactoring'
Plugin 'tpope/vim-endwise'
Plugin 'elixir-lang/vim-elixir'

Plugin 'mattn/emmet-vim'
source ~/.fzf/plugin/fzf.vim
Plugin 'junegunn/fzf.vim'
Plugin 'tpope/vim-bundler'
Plugin 'tpope/vim-unimpaired'

" JS/React
Plugin 'pangloss/vim-javascript'
Plugin 'chemzqm/vim-jsx-improve'
Plugin 'scrooloose/syntastic'

" Clojure
" Plugin 'venantius/vim-cljfmt'
Plugin 'tpope/vim-classpath'
Plugin 'tpope/vim-fireplace.git'
Plugin 'guns/vim-clojure-static.git'
Plugin 'guns/vim-sexp'
Plugin 'tpope/vim-sexp-mappings-for-regular-people'
Plugin 'guns/vim-slamhound'
Plugin 'kien/rainbow_parentheses.vim'

Plugin 'ekalinin/Dockerfile.vim'
Plugin 'majutsushi/tagbar'

" Slow
" #Plugin 'neoclide/coc.nvim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""" BASIC EDITING CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
" allow unsaved background buffers and remember marks/undo for them
set hidden
" remember more commands and search history
set history=10000
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set laststatus=2
set showmatch
set incsearch
set hlsearch
set number
" make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
" highlight current line
set cursorline
set cmdheight=2
set switchbuf=useopen
set numberwidth=5
set showtabline=2
set winwidth=79
" set shell=zsh
set number
" Prevent Vim from clobbering the scrollback buffer. See
" http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=
" keep more context when scrolling off the end of a buffer
set scrolloff=3
" Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/tmp,/var/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/tmp,/var/tmp
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" display incomplete commands
set showcmd
" Enable highlighting for syntax
syntax on
"use emacs-style tab completion when selecting files, etc
set wildmode=longest,list
" make tab completion for files/buffers act like bash
set wildmenu
let mapleader=","
set wildignore+=*/node_modules/*,*/babel/*

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CUSTOM AUTOCMDS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup vimrcEx
  " Clear all autocmds in the group
  autocmd!
  autocmd FileType text setlocal textwidth=80
  " Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  "for ruby, autoindent with two spaces, always expand tabs
  autocmd FileType ruby,haml,eruby,yaml,javascript,html,sass,cucumber set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et

  autocmd! BufRead,BufNewFile *.sass setfiletype sass 

  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  " Indent div & p tags
  "autocmd FileType html,eruby if g:html_indent_tags !~ '\\|p\>' | let g:html_indent_tags .= '\|p\|li\|dt\|dd\|div' | endif

  " Don't syntax highlight markdown because it's often wrong
  autocmd! FileType mkd setlocal syn=off

  " Don't wrap location or quickfix lists
  autocmd FileType qf setlocal nowrap
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" COLOR
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set term=screen-256color
" let g:solarized_termcolors=256
" let g:solarized_termtrans=0
:set t_Co=256 " 256 colors
set background=light
colorscheme solarized

" Preserve indentation while pasting text from the OS X clipboard
noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STATUS LINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MISC KEY MAPS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <leader>y "+y
" Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
" Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>
" Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>
" Clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>
nnoremap <leader><leader> <c-^>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" STRIP TRAILING WHITESPACE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfunction

autocmd BufWritePre *.cljs,*.clj,*.h,*.c,*.java,*.rb :call <SID>StripTrailingWhitespaces()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Md5 COMMAND
" Show the MD5 of the current buffer
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -range Md5 :echo system('echo '.shellescape(join(getline(<line1>, <line2>), '\n')) . '| md5')

function! Check256()
  if &t_Co != 256 && ! has("gui_running")
    echomsg ""
    echomsg "err: please use GUI or a 256-color terminal (so that t_Co=256 could be set)"
    echomsg ""
    finish
  else
    echomsg ""
    echomsg "working!"
    echomsg ""
  endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntastic
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
nnoremap <Leader>l :SyntasticCheck<CR>
let g:bufferline_echo = 0

" enable eslint
let g:syntastic_javascript_checkers = ['eslint'] 

if has('statusline')
set laststatus=2
" Broken down into easily includeable segments
set statusline=%{fugitive#statusline()} "  Git Hotness
set statusline+=\%<%f\    " Filename
set statusline+=%w%h%m%r " Options
set statusline+=\ %y            " filetype
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_enable_signs=1
set statusline+=%=   
set statusline+=%l/%L  " Right aligned file nav info
endif

set diffopt+=vertical
au BufNewFile,BufRead *.es6 set filetype=javascript
au BufRead,BufNewFile *.json set filetype=json

function! PgpEncrypt(username)
    exec "w !keybase pgp encrypt " . a:username . " |pbcopy"
endfunction

" Clojure
autocmd Filetype clojure nmap <buffer> gf <Plug>FireplaceDjump
autocmd Filetype clojure nnoremap <buffer> <leader>sh :Slamhound<cr>

" let g:rbpt_colorpairs = [
"   \ ['blue',        '#FF6000'],
"   \ ['cyan',        '#00FFFF'],
"   \ ['darkgreen',   '#00FF00'],
"   \ ['LightYellow', '#c0c0c0'],
"   \ ['blue',        '#FF6000'],
"   \ ['cyan',        '#00FFFF'],
"   \ ['darkgreen',   '#00FF00'],
"   \ ['LightYellow', '#c0c0c0'],
"   \ ['blue',        '#FF6000'],
"   \ ['cyan',        '#00FFFF'],
"   \ ['darkgreen',   '#00FF00'],
"   \ ['LightYellow', '#c0c0c0'],
"   \ ['blue',        '#FF6000'],
"   \ ['cyan',        '#00FFFF'],
"   \ ['darkgreen',   '#00FF00'],
"   \ ['LightYellow', '#c0c0c0'],
"   \ ]
let g:rbpt_max = 16

autocmd BufEnter *.cljs,*.clj,*.cljs.hl RainbowParenthesesActivate
autocmd BufEnter *.cljs,*.clj,*.cljs.hl RainbowParenthesesLoadRound
autocmd BufEnter *.cljs,*.clj,*.cljs.hl RainbowParenthesesLoadSquare
autocmd BufEnter *.cljs,*.clj,*.cljs.hl RainbowParenthesesLoadBraces

function! IsFireplaceConnected()
  try
    return has_key(fireplace#platform(), 'connection')
  catch /Fireplace: :Connect to a REPL or install classpath.vim/
    return 0 " false
  endtry
endfunction

function! NreplStatusLine()
  if IsFireplaceConnected()
    return 'nREPL Connected'
  else
    return 'No nREPL Connection'
  endif
endfunction

function! SetBasicStatusLine()
  set statusline=%f   " path to file
  set statusline+=\   " separator
  set statusline+=%m  " modified flag
  set statusline+=%=  " switch to right side
  set statusline+=%y  " filetype of file
endfunction

autocmd Filetype clojure call SetBasicStatusLine()
autocmd Filetype clojure set statusline+=\ [%{NreplStatusLine()}]  " REPL connection status
autocmd BufEnter *.cljs,*.clj,*.cljs.hl  call SetBasicStatusLine()
autocmd BufLeave *.cljs,*.clj,*.cljs.hl  call SetBasicStatusLine()
let g:fireplace_cljs_repl = '(shadow/repl :frontend)'

" fzf config
autocmd Filetype ruby let g:fzf_tags_command = 'ctags -R --languages=ruby --exclude=.git --exclude=log --exclude=.terraform . $(bundle list --paths)' 
autocmd Filetype clojure let g:fzf_tags_command = 'ctags -R --languages=Clojure --exclude=.git --exclude=log --exclude=.terraform .' 
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fg :GFiles<CR>
nnoremap <silent> <leader>ft :Tags<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fc :Commits<CR>

setglobal complete=.,t,b

nmap <F8> :TagbarToggle<CR>

