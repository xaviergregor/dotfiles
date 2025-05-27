syntax on
set background=dark
set termguicolors
set mouse=a
set ignorecase
set tabstop=2
set shiftwidth=2
set expandtab
set ai
set number
set hlsearch
set ruler
set nocompatible

let g:dracula_colorterm = 0

call plug#begin('~/.vim/plugged')
"Plug 'nordtheme/vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()
colorscheme dracula
