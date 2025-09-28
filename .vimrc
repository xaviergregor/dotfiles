syntax on
set background=dark
set termguicolors
set mouse=a
set ignorecase
set ai
set number
set hlsearch
set ruler
set nocompatible

let g:dracula_colorterm = 0
let g:airline_theme='dracula'

call plug#begin('~/.vim/plugged')
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()
colorscheme dracula

