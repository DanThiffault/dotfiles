vim9script

set shell=/bin/zsh
set nocompatible              # be iMproved, required
filetype off                  # required

# set the runtime path to include Vundle and initialize
call plug#begin()

# Git integration and GBrowse
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

# Fuzzy Search
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'

# Intelligently add closing structures
Plug 'tpope/vim-endwise'

# Vim script helpers
Plug 'vim-scripts/L9'

#Plug 'altercation/vim-colors-solarized'
Plug 'liuchengxu/space-vim-theme'

# Add/remove comments with gc/gcgc
Plug 'tpope/vim-commentary'

# UNIX Shell integration
Plug 'tpope/vim-eunuch'

# Expand HTML abbreviations
Plug 'mattn/emmet-vim'

# Paired navigation shortcuts
Plug 'tpope/vim-unimpaired'

# Elixir 
Plug 'elixir-editors/vim-elixir'

# Vim Langugage Server integration
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'

# All of your Plugins must be added before the following line
call plug#end()

filetype plugin indent on    # required

##################################################################################
##### BASIC EDITING CONFIGURATION
##################################################################################
set nocompatible
# allow unsaved background buffers and remember marks/undo for them
set hidden
# remember more commands and search history
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
# make searches case-sensitive only if they contain upper-case characters
set ignorecase smartcase
# highlight current line
set cursorline
set cmdheight=2
set switchbuf=useopen
set numberwidth=5
set showtabline=2
set winwidth=79
# set shell=zsh
set number
# Prevent Vim from clobbering the scrollback buffer. See
# http://www.shallowsky.com/linux/noaltscreen.html
set t_ti= t_te=
# keep more context when scrolling off the end of a buffer
set scrolloff=3
# Store temporary files in a central spot
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/tmp,/var/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/tmp,/var/tmp
# allow backspacing over everything in insert mode
set backspace=indent,eol,start
# display incomplete commands
set showcmd
# Enable highlighting for syntax
syntax on
#use emacs-style tab completion when selecting files, etc
set wildmode=longest,list
# make tab completion for files/buffers act like bash
set wildmenu
g:mapleader = ","
set wildignore+=*/node_modules/*,*/babel/*

##############################################################################
# CUSTOM AUTOCMDS
##############################################################################
augroup vimrcEx
  # Clear all autocmds in the group
  autocmd!
  autocmd FileType text setlocal textwidth=80
  # Jump to last cursor position unless it's invalid or in an event handler
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  #for ruby, autoindent with two spaces, always expand tabs
  autocmd FileType ruby,haml,eruby,yaml,javascript,html,sass,cucumber set ai sw=2 sts=2 et
  autocmd FileType python set sw=4 sts=4 et

  autocmd! BufRead,BufNewFile *.sass setfiletype sass 

  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
  autocmd BufRead *.markdown  set ai formatoptions=tcroqn2 comments=n:&gt;

  # Don't syntax highlight markdown because it's often wrong
  autocmd! FileType mkd setlocal syn=off

  # Don't wrap location or quickfix lists
  autocmd FileType qf setlocal nowrap

  # Shortcut to zoom panes h & v
  nmap <c-w>z <c-w>_<c-w><bar>

augroup END

##############################################################################
# COLOR
##############################################################################
set term=screen-256color
:set t_Co=256 # 256 colors
set termguicolors
set background=dark
colorscheme space_vim_theme
hi Comment guifg=#5C6370 ctermfg=59
hi LineNr ctermbg=NONE guibg=NONE

# Preserve indentation while pasting text from the OS X clipboard
noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>

##############################################################################
# STATUS LINE
##############################################################################

##############################################################################
# MISC KEY MAPS
##############################################################################
map <leader>y #+y
# Move around splits with <c-hjkl>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
# Insert a hash rocket with <c-l>
imap <c-l> <space>=><space>
# Can't be bothered to understand ESC vs <c-c> in insert mode
imap <c-c> <esc>
# Clear the search buffer when hitting return
:nnoremap <CR> :nohlsearch<cr>
nnoremap <leader><leader> <c-^>

##############################################################################
# STRIP TRAILING WHITESPACE
##############################################################################
def StripTrailingWhitespaces()
  var l = line(#.#)
  var c = col(#.#)
  %s/\s\+$//e
  call cursor(l, c)
enddef

autocmd BufWritePre *.py,*.cljs,*.clj,*.h,*.c,*.java,*.rb :StripTrailingWhitespaces()

##############################################################################
# RENAME CURRENT FILE
##############################################################################
def RenameFile()
    var old_name = expand('%')
    var new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
enddef

##############################################################################
# Md5 COMMAND
# Show the MD5 of the current buffer
##############################################################################
command! -range Md5 :echo system('echo '.shellescape(join(getline(<line1>, <line2>), '\n')) . '| md5')

def Check256()
  if &t_Co != 256 && ! has(#gui_running#)
    echomsg ##
    echomsg #err: please use GUI or a 256-color terminal (so that t_Co=256 could be set)#
    echomsg ##
    finish
  else
    echomsg ##
    echomsg #working!#
    echomsg ##
  endif
enddef

if has('statusline')
set laststatus=2
# Broken down into easily includeable segments
set statusline=%{fugitive#statusline()} #  Git Hotness
set statusline+=\%<%f\    # Filename
set statusline+=%w%h%m%r # Options
set statusline+=\ %y            # filetype
set statusline+=%#warningmsg#
#set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%=   
set statusline+=%l/%L  # Right aligned file nav info
set statusline+=\ \|     # Right aligned file nav info
set statusline+=%c 
endif

set diffopt-=internal
set diffopt+=vertical
au BufNewFile,BufRead *.es6 set filetype=javascript
au BufRead,BufNewFile *.json set filetype=json

def PgpEncrypt(username: string): string
    exec "w !keybase pgp encrypt " . a:username . " |xclip -sel clip -i"
enddef

def PgpDecrypt(): string
    exec "r !xclip -sel clip -o | keybase pgp decrypt"
enddef

def SetBasicStatusLine()
  set statusline=%f   # path to file
  set statusline+=\   # separator
  set statusline+=%m  # modified flag
  set statusline+=%=  # switch to right side
  set statusline+=%y  # filetype of file
enddef

# fzf config
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)
nnoremap <silent> <leader>ff :Files<CR>
nnoremap <silent> <leader>fg :GFiles<CR>
nnoremap <silent> <leader>fb :Buffers<CR>
nnoremap <silent> <leader>fc :Commits<CR>
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

# fugitive config
nnoremap <leader>dx :diffget //2<CR>
nnoremap <leader>dc :diffget //3<CR>

g:lsp_log_verbose = 0
g:lsp_log_file = expand('/tmp/vim-lsp.log')

# for asyncomplete.vim log
g:asyncomplete_log_file = expand('/tmp/asyncomplete.log')

def OnLspBufferEnabled() 
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    #nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> <leader>= <plug>(lsp-document-format)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    # g:lsp_format_sync_timeout = 5000
    # autocmd! BufWritePre * :LspDocumentFormatSync

    # General Vim-LSP settings
    set foldmethod=expr
                \ foldexpr=lsp#ui#vim#folding#foldexpr()
                \ foldtext=lsp#ui#vim#folding#foldtext()

    # LSP autocomplete
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"
enddef

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call OnLspBufferEnabled()
augroup end

# Configure Lexical for elixir language server
g:lsp_settings_filetype_elixir = ["lexical"]

if executable("elixir")
    augroup lsp_lexical
    autocmd!
    autocmd User lsp_setup call lsp#register_server({ name: "lexical", cmd: (server_info) => "/Users/dan/.lexical/_build/dev/package/lexical/bin/start_lexical.sh", allowlist: ["elixir", "eelixir"] })
    autocmd FileType elixir setlocal omnifunc=lsp#complete
    autocmd FileType eelixir setlocal omnifunc=lsp#complete
    augroup end
endif
