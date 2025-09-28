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

let g:airline_theme='simple'

call plug#begin('~/.vim/plugged')
Plug 'ayu-theme/ayu-vim'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()
colorscheme ayu

