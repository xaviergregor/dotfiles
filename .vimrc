set nocompatible
filetype plugin indent on
syntax on
set hidden
set background=dark
set termguicolors
set mouse=a
set ignorecase
set smartcase
set incsearch
set tabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set number
set hlsearch
set ruler
set signcolumn=yes
set shortmess+=c
set lazyredraw
set ttyfast
set synmaxcol=200

let mapleader=" "
let g:airline_theme = 'minimalist'

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :Rg<CR>
nnoremap <leader>b :Buffers<CR>

colorscheme industry

" Force background after colorscheme
highlight Normal        guibg=#080808 ctermbg=232
highlight LineNr        guibg=#080808 ctermbg=232
highlight SignColumn    guibg=#080808 ctermbg=232
highlight FoldColumn    guibg=#080808 ctermbg=232
highlight CursorLineNr  guibg=#080808 ctermbg=232
highlight EndOfBuffer   guibg=#080808 ctermbg=232
highlight NonText       guibg=#080808 ctermbg=232
